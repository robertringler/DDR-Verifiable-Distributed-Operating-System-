import { useStats } from '../../hooks/useListings'
import { timeAgo } from '../../lib/utils'
import type { Page } from '../../App'

const NAV: { id: Page; label: string }[] = [
  { id: 'dashboard', label: 'Dashboard' },
  { id: 'opportunities', label: 'Opportunities' },
  { id: 'analytics', label: 'Analytics' },
  { id: 'watchlist', label: 'Watchlist' },
  { id: 'portfolio', label: 'Portfolio' }
]

export default function Header({ page, onNav }: { page: Page; onNav: (p: Page) => void }) {
  const { data: stats } = useStats()

  return (
    <header style={{
      background: 'var(--surface)',
      borderBottom: '1px solid var(--border)',
      padding: '0 24px',
      display: 'flex',
      alignItems: 'center',
      gap: '32px',
      height: '56px',
      position: 'sticky',
      top: 0,
      zIndex: 100
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        <span style={{ fontFamily: 'var(--display)', fontSize: '24px', color: 'var(--green)', letterSpacing: '0.05em' }}>
          FLIPRADAR
        </span>
        <span style={{
          display: 'flex', alignItems: 'center', gap: '5px',
          fontSize: '9px', color: 'var(--green)', fontWeight: 600, letterSpacing: '0.08em'
        }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--green)', animation: 'pulse-green 1.5s infinite' }} />
          LIVE
        </span>
      </div>

      <nav style={{ display: 'flex', gap: '4px', flex: 1 }}>
        {NAV.map(n => (
          <button
            key={n.id}
            onClick={() => onNav(n.id)}
            style={{
              padding: '6px 14px',
              fontSize: '11px',
              fontFamily: 'var(--mono)',
              fontWeight: 500,
              letterSpacing: '0.05em',
              color: page === n.id ? 'var(--text-bright)' : 'var(--text)',
              background: page === n.id ? 'rgba(16,185,129,0.1)' : 'none',
              border: page === n.id ? '1px solid rgba(16,185,129,0.3)' : '1px solid transparent',
              borderRadius: '5px',
              transition: 'all 0.15s'
            }}
          >
            {n.label}
          </button>
        ))}
      </nav>

      <div style={{ fontSize: '10px', color: 'var(--text)', whiteSpace: 'nowrap' }}>
        {stats ? `${stats.total} deals · updated ${timeAgo(stats.lastRefresh)}` : 'Loading...'}
      </div>
    </header>
  )
}
