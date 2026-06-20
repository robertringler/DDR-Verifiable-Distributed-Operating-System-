#!/usr/bin/env python3
"""
Numerical verification of Theorem K (CIIR observer-map non-contraction).

Theorem K (see ../theorem-K-note.md): for N_beta(rho) = rho^beta / Tr(rho^beta),
beta in (0,1), on d x d density matrices, d >= 2:
  (1) N_beta fixes BOTH the maximally mixed state I/d AND every pure state;
  (2) near I/d, N_beta is locally a strict contraction with constant -> beta;
  (3) near any pure state, N_beta is EXPANSIVE with local ratio -> infinity.
Hence N_beta is NOT a strict contraction (a strict contraction has a unique
fixed point), refuting ch13 Thm 13.2 Step 2 of the CIIR monograph.

This script confirms (1)-(3) numerically and prints the measured quantities.
Run:  python3 verify_theorem_k.py
"""
import numpy as np

np.random.seed(0)


def Nbeta(rho, beta):
    """The CIIR observer/sharpening map rho^beta / Tr(rho^beta)."""
    w, V = np.linalg.eigh(rho)
    w = np.clip(w, 0.0, None)            # numerical floor at 0
    wb = np.where(w > 0, w**beta, 0.0)   # 0^beta = 0 for beta > 0
    M = (V * wb) @ V.conj().T
    return M / np.trace(M).real


def trace_norm(A):
    """Schatten-1 (trace) norm = sum of singular values."""
    return np.sum(np.linalg.svd(A, compute_uv=False))


def rand_traceless_herm(d):
    """A random traceless Hermitian matrix (tangent direction at I/d)."""
    A = np.random.randn(d, d) + 1j * np.random.randn(d, d)
    H = (A + A.conj().T) / 2
    H -= np.trace(H).real / d * np.eye(d)   # project out the trace
    return H / trace_norm(H)                 # unit trace-norm


def pure_state(d, k=0):
    v = np.zeros(d, dtype=complex)
    v[k] = 1.0
    return np.outer(v, v.conj())


def check_fixed_points(d, beta, tol=1e-10):
    I = np.eye(d) / d
    res_mix = trace_norm(Nbeta(I, beta) - I)
    pure = pure_state(d)
    res_pure = trace_norm(Nbeta(pure, beta) - pure)
    return res_mix, res_pure


def local_ratio_at_mixed(d, beta, eps):
    """Measured ||N(I/d + eps X) - I/d|| / ||eps X|| for small eps. -> beta."""
    I = np.eye(d) / d
    X = rand_traceless_herm(d)
    rho = I + eps * X
    # ensure a valid density matrix (PSD, trace 1) for small eps
    rho = (rho + rho.conj().T) / 2
    return trace_norm(Nbeta(rho, beta) - I) / (eps * trace_norm(X))


def expansion_near_pure(d, beta, eps):
    """Trace-distance ratio approaching a pure state. -> infinity as eps->0."""
    psi = pure_state(d, 0)
    phi = pure_state(d, 1)
    rho = (1 - eps) * psi + eps * phi
    num = trace_norm(Nbeta(rho, beta) - psi)
    den = trace_norm(rho - psi)
    return num / den


def iterate(rho, beta, steps):
    for _ in range(steps):
        rho = Nbeta(rho, beta)
    return rho


def rand_density(d):
    A = np.random.randn(d, d) + 1j * np.random.randn(d, d)
    M = A @ A.conj().T
    return M / np.trace(M).real


def main():
    print("=" * 72)
    print("Theorem K — numerical verification")
    print("=" * 72)

    betas = [0.60, 0.75, 0.90]
    dims = [2, 3, 4]

    print("\n(1) TWO FIXED POINTS: residual ||N(x)-x||_1 at I/d and at a pure state")
    print(f"    {'d':>2} {'beta':>5} {'res(I/d)':>12} {'res(pure)':>12}")
    ok1 = True
    for d in dims:
        for b in betas:
            rm, rp = check_fixed_points(d, b)
            ok1 = ok1 and rm < 1e-9 and rp < 1e-9
            print(f"    {d:>2} {b:>5.2f} {rm:>12.2e} {rp:>12.2e}")
    print(f"    => both are fixed points (residuals ~ 0): {ok1}")
    print("    => >= 2 distinct fixed points => NOT a strict contraction "
          "(Banach uniqueness).")

    print("\n(2) LOCAL CONTRACTION AT I/d: ratio ||N(I/d+eps X)-I/d|| / ||eps X|| "
          "-> beta")
    print(f"    {'d':>2} {'beta':>5} {'eps=1e-2':>10} {'eps=1e-4':>10} "
          f"{'eps=1e-6':>10} {'target':>8}")
    ok2 = True
    for d in dims:
        for b in betas:
            rs = [np.mean([local_ratio_at_mixed(d, b, e) for _ in range(200)])
                  for e in (1e-2, 1e-4, 1e-6)]
            ok2 = ok2 and abs(rs[-1] - b) < 2e-2
            print(f"    {d:>2} {b:>5.2f} {rs[0]:>10.4f} {rs[1]:>10.4f} "
                  f"{rs[2]:>10.4f} {b:>8.2f}")
    print(f"    => ratio converges to beta (< 1): local strict contraction at I/d: "
          f"{ok2}")

    print("\n(3) EXPANSION NEAR A PURE STATE: ratio ||N(rho_eps)-pure|| / "
          "||rho_eps-pure|| -> inf")
    print(f"    {'d':>2} {'beta':>5} {'eps=1e-2':>10} {'eps=1e-4':>10} "
          f"{'eps=1e-6':>10} {'eps=1e-8':>12}")
    ok3 = True
    for d in dims:
        for b in betas:
            rs = [expansion_near_pure(d, b, e) for e in (1e-2, 1e-4, 1e-6, 1e-8)]
            ok3 = ok3 and rs[-1] > rs[0] > 1.0   # growing and > 1
            print(f"    {d:>2} {b:>5.2f} {rs[0]:>10.3f} {rs[1]:>10.3f} "
                  f"{rs[2]:>10.3f} {rs[3]:>12.3f}")
    print(f"    => ratio grows without bound (expansive near pure states): {ok3}")
    print("    (analytic prediction: ratio ~ eps^(beta-1) -> infinity)")

    print("\n(4) DYNAMICS: I/d is ATTRACTING, pure states are REPELLING")
    d, b = 3, 0.7
    lims = []
    for _ in range(5):
        lim = iterate(rand_density(d), b, 400)
        lims.append(trace_norm(lim - np.eye(d) / d))
    pure_stays = trace_norm(iterate(pure_state(d), b, 400) - pure_state(d))
    print(f"    full-rank starts -> distance to I/d after 400 steps: "
          f"{[f'{x:.2e}' for x in lims]}")
    print(f"    pure-state start -> distance to its own pure state: "
          f"{pure_stays:.2e} (stays fixed)")
    ok4 = max(lims) < 1e-6 and pure_stays < 1e-9
    print(f"    => distinct basins: full-rank -> I/d, pure -> pure: {ok4}")

    print("\n" + "=" * 72)
    allok = ok1 and ok2 and ok3 and ok4
    print(f"THEOREM K NUMERICALLY CONFIRMED: {allok}")
    print("  (1) two fixed points  (2) contraction beta at I/d  "
          "(3) expansion near pure  (4) distinct basins")
    print("=" * 72)
    return 0 if allok else 1


if __name__ == "__main__":
    raise SystemExit(main())
