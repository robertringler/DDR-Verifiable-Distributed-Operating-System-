import type { SignalClass } from '../../types'
import { sigColor, classifyLabel } from '../../lib/utils'

interface Props {
  cls: SignalClass
}

export default function Badge({ cls }: Props) {
  const color = sigColor(cls)
  const label = classifyLabel(cls)
  return (
    <span style={{
      fontSize: '9px',
      fontFamily: 'var(--mono)',
      fontWeight: 600,
      letterSpacing: '0.08em',
      color,
      border: `1px solid ${color}`,
      borderRadius: '3px',
      padding: '2px 5px',
      whiteSpace: 'nowrap'
    }}>
      {label}
    </span>
  )
}
