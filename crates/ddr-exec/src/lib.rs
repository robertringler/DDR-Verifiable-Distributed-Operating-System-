//! `ddr-exec` — deterministic execution (`wasm_ddr`) + replay (DDR Vol. I Ch. 6–9).
//!
//! Three pieces, each addressing a specific spec claim and a specific audit note:
//!
//!  * **`validate`** — the `wasm_ddr` admissibility gate (Def. 7.1, Ch. 7.3):
//!    a syntactic filter that rejects the nondeterminism-bearing instruction
//!    classes (floating point, SIMD, atomics/threads) and host imports.
//!  * **`WasmKernel`** — the pure execution kernel `K` (Def. 6.1), run on a
//!    *pure-Rust interpreter* (`wasmi`) so results are identical on any
//!    architecture (Thm. 6.2 / 7.2). Each step gets a fresh `Store`, so `K` is a
//!    genuine pure function of `(state, tx)`.
//!  * **`verify_trace`** — the replay engine (Ch. 9, Inv. 9.2 "bit-perfect
//!    replay"): re-execute a recorded trace and check every state root matches;
//!    tampering is detected.
//!
//! ### Honest scope (audit `docs/audit/10-...`)
//!
//! The spec's Thm. 7.2 *asserts* the ban list is the **exclusive** source of
//! WASM nondeterminism. We do **not** prove that. `validate` enforces an
//! explicit, documented ban list (`BANNED_CLASSES`); the determinism we then
//! get is from `wasmi`'s deterministic interpreter, and is *tested*, not proven
//! complete. Known residual nondeterminism sources we rely on `wasmi` to make
//! deterministic (resource exhaustion ordering, `memory.grow` failure) are noted
//! rather than swept aside.

use ddr_core::Hash32;
use wasmi::{Engine, Linker, Module, Store};

/// The execution world-state. A single 64-bit register: minimal, but enough to
/// demonstrate *real computation* whose result the state root commits to
/// (unlike `ddr-core::reduce`, which commits only to opaque tx bytes).
pub type State = u64;

/// An execution transaction: the operand handed to the kernel's `apply`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ExecTx(pub u64);

/// Per-step execution receipt (the unit the replay engine checks).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Receipt {
    pub index: u64,
    pub pre: State,
    pub tx: u64,
    pub post: State,
    pub root: Hash32,
}

/// Instruction classes banned from `wasm_ddr` (the determinism-relevant ones).
pub const BANNED_CLASSES: &[&str] = &["floating-point", "SIMD", "atomics/threads"];

/// Memory cap (pages of 64 KiB). `memory.grow` past this fails deterministically.
pub const MAX_MEM_PAGES: u64 = 1024; // 64 MiB

#[derive(Debug, PartialEq, Eq)]
pub enum ValidationError {
    Banned { op: String, class: &'static str },
    HasImport(String),
    SharedMemory,
    MemoryTooLarge { pages: u64, max: u64 },
    Parse(String),
}

#[derive(Debug)]
pub enum KernelError {
    Validation(ValidationError),
    Compile(String),
    NoApplyExport,
    Trap(String),
    Instantiate(String),
}

impl From<ValidationError> for KernelError {
    fn from(e: ValidationError) -> Self {
        KernelError::Validation(e)
    }
}

/// Classify an operator as banned, or `None` if admissible. Conservative
/// syntactic filter over the operator's name (floats `F32*/F64*`, SIMD `V128*`
/// and lane ops `*x2/x4/x8/x16`, anything `*Atomic*`).
fn banned_class(op: &wasmparser::Operator) -> Option<&'static str> {
    let name = format!("{op:?}");
    let n = name.as_str();
    if n.starts_with("F32") || n.starts_with("F64") {
        Some("floating-point")
    } else if n.contains("V128")
        || n.contains("x16")
        || n.contains("x8")
        || n.contains("x4")
        || n.contains("x2")
    {
        Some("SIMD")
    } else if n.contains("Atomic") {
        Some("atomics/threads")
    } else {
        None
    }
}

/// The `wasm_ddr` admissibility gate.
pub fn validate(bytes: &[u8]) -> Result<(), ValidationError> {
    use wasmparser::{Parser, Payload};
    for payload in Parser::new(0).parse_all(bytes) {
        let payload = payload.map_err(|e| ValidationError::Parse(e.to_string()))?;
        match payload {
            // No host ABI in this PoC: imports could reintroduce nondeterminism,
            // so the deterministic ABI is "empty".
            Payload::ImportSection(reader) => {
                for imp in reader.into_imports() {
                    let imp = imp.map_err(|e| ValidationError::Parse(e.to_string()))?;
                    return Err(ValidationError::HasImport(format!(
                        "{}::{}",
                        imp.module, imp.name
                    )));
                }
            }
            Payload::MemorySection(reader) => {
                for mem in reader {
                    let mem = mem.map_err(|e| ValidationError::Parse(e.to_string()))?;
                    if mem.shared {
                        return Err(ValidationError::SharedMemory);
                    }
                    if mem.initial > MAX_MEM_PAGES {
                        return Err(ValidationError::MemoryTooLarge {
                            pages: mem.initial,
                            max: MAX_MEM_PAGES,
                        });
                    }
                }
            }
            Payload::CodeSectionEntry(body) => {
                let reader = body
                    .get_operators_reader()
                    .map_err(|e| ValidationError::Parse(e.to_string()))?;
                for op in reader {
                    let op = op.map_err(|e| ValidationError::Parse(e.to_string()))?;
                    if let Some(class) = banned_class(&op) {
                        return Err(ValidationError::Banned {
                            op: format!("{op:?}"),
                            class,
                        });
                    }
                }
            }
            _ => {}
        }
    }
    Ok(())
}

/// A compiled, validated `wasm_ddr` execution kernel.
pub struct WasmKernel {
    engine: Engine,
    module: Module,
}

impl WasmKernel {
    /// Validate the subset, compile, and confirm the `apply(i64,i64)->i64`
    /// export exists. Rejects inadmissible modules.
    pub fn from_wasm(bytes: &[u8]) -> Result<Self, KernelError> {
        validate(bytes)?;
        let engine = Engine::default();
        let module = Module::new(&engine, bytes).map_err(|e| KernelError::Compile(e.to_string()))?;
        let k = WasmKernel { engine, module };
        // Probe that the export is present and well-typed.
        let mut store = Store::new(&k.engine, ());
        let linker = Linker::new(&k.engine);
        let inst = linker
            .instantiate_and_start(&mut store, &k.module)
            .map_err(|e| KernelError::Instantiate(e.to_string()))?;
        inst.get_typed_func::<(i64, i64), i64>(&store, "apply")
            .map_err(|_| KernelError::NoApplyExport)?;
        Ok(k)
    }

    /// The pure kernel `K(state, tx) -> state`. Fresh `Store` per call ⇒ no
    /// hidden state survives between transactions.
    pub fn apply(&self, state: State, tx: u64) -> Result<State, KernelError> {
        let mut store = Store::new(&self.engine, ());
        let linker = Linker::new(&self.engine);
        let inst = linker
            .instantiate_and_start(&mut store, &self.module)
            .map_err(|e| KernelError::Instantiate(e.to_string()))?;
        let f = inst
            .get_typed_func::<(i64, i64), i64>(&store, "apply")
            .map_err(|_| KernelError::NoApplyExport)?;
        let out = f
            .call(&mut store, (state as i64, tx as i64))
            .map_err(|e| KernelError::Trap(e.to_string()))?;
        Ok(out as u64)
    }

    /// Execute an ordered log, producing the final state, the canonical state
    /// root (committing to every *computed* post-state), and per-step receipts.
    pub fn run(
        &self,
        genesis_root: Hash32,
        genesis_state: State,
        txs: &[ExecTx],
    ) -> Result<(State, Hash32, Vec<Receipt>), KernelError> {
        let mut state = genesis_state;
        let mut root = genesis_root;
        let mut receipts = Vec::with_capacity(txs.len());
        for (i, tx) in txs.iter().enumerate() {
            let post = self.apply(state, tx.0)?;
            root = step_root(root, post);
            receipts.push(Receipt {
                index: i as u64,
                pre: state,
                tx: tx.0,
                post,
                root,
            });
            state = post;
        }
        Ok((state, root, receipts))
    }
}

/// State-root fold over computed post-states (Def. 1.2 specialized to execution).
pub fn step_root(prev: Hash32, post: State) -> Hash32 {
    Hash32::of(&[b"exec", &prev.0, &post.to_le_bytes()])
}

/// Replay engine (Inv. 9.2): re-execute a recorded trace and check that every
/// post-state and state root reproduces bit-for-bit. Returns `false` on any
/// mismatch (e.g. a tampered transaction).
pub fn verify_trace(
    kernel: &WasmKernel,
    genesis_root: Hash32,
    genesis_state: State,
    receipts: &[Receipt],
) -> Result<bool, KernelError> {
    let mut state = genesis_state;
    let mut root = genesis_root;
    for r in receipts {
        let post = kernel.apply(state, r.tx)?;
        root = step_root(root, post);
        if post != r.post || root != r.root {
            return Ok(false);
        }
        state = post;
    }
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;

    // apply(state, tx) = state + tx   (pure integer transition)
    const ADDER: &str = r#"(module (func (export "apply") (param i64 i64) (result i64)
        local.get 0 local.get 1 i64.add))"#;
    // apply(state, tx) = state * 2 + tx
    const MULADD: &str = r#"(module (func (export "apply") (param i64 i64) (result i64)
        local.get 0 i64.const 2 i64.mul local.get 1 i64.add))"#;

    fn kernel(wat: &str) -> WasmKernel {
        WasmKernel::from_wasm(&wat::parse_str(wat).unwrap()).unwrap()
    }
    fn txs(v: &[u64]) -> Vec<ExecTx> {
        v.iter().map(|x| ExecTx(*x)).collect()
    }

    #[test]
    fn executes_real_computation() {
        let k = kernel(ADDER);
        assert_eq!(k.apply(40, 2).unwrap(), 42);
        let k2 = kernel(MULADD);
        assert_eq!(k2.apply(10, 1).unwrap(), 21);
    }

    #[test]
    fn execution_is_deterministic() {
        let k = kernel(MULADD);
        let log = txs(&[3, 5, 7, 11, 13]);
        let (s1, r1, _) = k.run(Hash32::zero(), 0, &log).unwrap();
        for _ in 0..50 {
            let (s, r, _) = k.run(Hash32::zero(), 0, &log).unwrap();
            assert_eq!((s, r), (s1, r1), "kernel must be deterministic across runs");
        }
    }

    #[test]
    fn two_independent_kernels_agree() {
        // Cross-"platform" reproducibility (Thm 19.2 / Inv 9.2): two kernels
        // built from the same bytes produce identical roots.
        let bytes = wat::parse_str(MULADD).unwrap();
        let a = WasmKernel::from_wasm(&bytes).unwrap();
        let b = WasmKernel::from_wasm(&bytes).unwrap();
        let log = txs(&[1, 2, 3, 4, 5, 6]);
        let (_, ra, _) = a.run(Hash32::zero(), 0, &log).unwrap();
        let (_, rb, _) = b.run(Hash32::zero(), 0, &log).unwrap();
        assert_eq!(ra, rb);
    }

    #[test]
    fn replay_verifies_and_detects_tampering() {
        let k = kernel(MULADD);
        let log = txs(&[9, 8, 7, 6, 5]);
        let (_, _, receipts) = k.run(Hash32::zero(), 0, &log).unwrap();
        assert!(verify_trace(&k, Hash32::zero(), 0, &receipts).unwrap());

        // Tamper one transaction's operand: replay must reject.
        let mut bad = receipts.clone();
        bad[2].tx ^= 1;
        assert!(!verify_trace(&k, Hash32::zero(), 0, &bad).unwrap(),
                "replay must detect a tampered transaction");

        // Tamper a recorded post-state: replay must reject.
        let mut bad2 = receipts.clone();
        bad2[3].post = bad2[3].post.wrapping_add(1);
        assert!(!verify_trace(&k, Hash32::zero(), 0, &bad2).unwrap());
    }

    #[test]
    fn validator_rejects_floating_point() {
        let float_mod = r#"(module (func (export "apply") (param i64 i64) (result i64)
            f64.const 1 drop local.get 0))"#;
        let bytes = wat::parse_str(float_mod).unwrap();
        match validate(&bytes) {
            Err(ValidationError::Banned { class, .. }) => assert_eq!(class, "floating-point"),
            other => panic!("expected float ban, got {other:?}"),
        }
        assert!(WasmKernel::from_wasm(&bytes).is_err());
    }

    #[test]
    fn validator_rejects_imports() {
        let import_mod = r#"(module (import "host" "rand" (func (result i64)))
            (func (export "apply") (param i64 i64) (result i64) local.get 0))"#;
        let bytes = wat::parse_str(import_mod).unwrap();
        assert!(matches!(validate(&bytes), Err(ValidationError::HasImport(_))));
    }

    #[test]
    fn validator_accepts_integer_module() {
        assert!(validate(&wat::parse_str(ADDER).unwrap()).is_ok());
        assert!(validate(&wat::parse_str(MULADD).unwrap()).is_ok());
    }

    #[test]
    fn missing_apply_export_is_rejected() {
        let no_apply = r#"(module (func (export "other") (param i64) (result i64) local.get 0))"#;
        let bytes = wat::parse_str(no_apply).unwrap();
        assert!(matches!(WasmKernel::from_wasm(&bytes), Err(KernelError::NoApplyExport)));
    }
}
