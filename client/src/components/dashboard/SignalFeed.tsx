import { useListings } from '../../hooks/useListings'
import { formatCurrency, formatROI, sigColor } from '../../lib/utils'
import SourceBadge from '../ui/SourceBadge'

export default function SignalFeed() {
  const { data: listings = [] } = useListings()
  const hot = listings.filter(l => l.classification === 'HOT_OPPORTUNITY' || l.classification === 'STRONG_SIGNAL').slice(0, 12)

  return (
    <div style={{
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      borderRadius: '8px',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden'
    }}>
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '8px' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--green)', animation: 'pulse-green 1.5s infinite', display: 'inline-block' }} />
        <span style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em' }}>SIGNAL FEED</span>
      </div>
      <div style={{ overflow: 'auto', flex: 1 }}>
        {hot.length === 0 && (
          <div style={{ padding: '20px', fontSize: '11px', color: 'var(--text)', textAlign: 'center' }}>Loading signals...</div>
        )}
        {hot.map(l => (
          <div key={l.id} style={{
            padding: '10px 16px',
            borderBottom: '1px solid var(--border)',
            display: 'flex',
            flexDirection: 'column',
            gap: '4px',
            borderLeft: `2px solid ${sigColor(l.classification)}`
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '8px' }}>
              <SourceBadge source={l.source} />
              <span style={{ fontSize: '12px', fontFamily: 'var(--display)', color: l.roi >= 0 ? 'var(--green)' : 'var(--red)', marginLeft: 'auto' }}>
                {formatROI(l.roi)}
              </span>
            </div>
            <p style={{ fontSize: '11px', color: 'var(--text-bright)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {l.title}
            </p>
            <div style={{ fontSize: '10px', color: 'var(--text)', display: 'flex', justifyContent: 'space-between' }}>
              <span>{formatCurrency(l.buyPrice)}</span>
              <span>→ {formatCurrency(l.estResalePrice)}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
