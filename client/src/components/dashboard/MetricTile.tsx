interface Props {
  label: string
  value: string | number
  sub?: string
  accent?: string
}

export default function MetricTile({ label, value, sub, accent = 'var(--green)' }: Props) {
  return (
    <div style={{
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      borderRadius: '8px',
      padding: '16px 20px',
      display: 'flex',
      flexDirection: 'column',
      gap: '4px'
    }}>
      <span style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.1em', textTransform: 'uppercase' }}>
        {label}
      </span>
      <span style={{ fontSize: '26px', fontFamily: 'var(--display)', color: accent, lineHeight: 1 }}>
        {value}
      </span>
      {sub && <span style={{ fontSize: '11px', color: 'var(--text)' }}>{sub}</span>}
    </div>
  )
}
