import { useFlipRadarStore } from '../../store/flipradarStore'

const SOURCES = [
  { id: 'all', label: 'All' },
  { id: 'ebay', label: 'eBay' },
  { id: 'govdeals', label: 'GovDeals' },
  { id: 'facebook', label: 'Facebook' }
]

const SORTS = [
  { id: 'roi', label: 'Best ROI' },
  { id: 'price', label: 'Lowest Price' },
  { id: 'risk', label: 'Lowest Risk' },
  { id: 'newest', label: 'Newest' }
]

export default function FilterBar() {
  const { filters, setFilters } = useFlipRadarStore()

  return (
    <div style={{
      background: 'var(--surface)',
      borderBottom: '1px solid var(--border)',
      padding: '12px 24px',
      display: 'flex',
      gap: '20px',
      alignItems: 'center',
      flexWrap: 'wrap'
    }}>
      <div style={{ display: 'flex', gap: '4px' }}>
        {SOURCES.map(s => (
          <button
            key={s.id}
            onClick={() => setFilters({ source: s.id })}
            style={{
              padding: '4px 10px',
              fontSize: '10px',
              fontFamily: 'var(--mono)',
              fontWeight: 600,
              letterSpacing: '0.05em',
              color: filters.source === s.id ? 'var(--bg)' : 'var(--text)',
              background: filters.source === s.id ? 'var(--green)' : 'var(--surface2)',
              border: '1px solid var(--border)',
              borderRadius: '4px'
            }}
          >
            {s.label}
          </button>
        ))}
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        <label style={{ fontSize: '10px', color: 'var(--text)' }}>Min ROI</label>
        <input
          type="range" min="0" max="200" step="5"
          value={filters.minROI}
          onChange={e => setFilters({ minROI: Number(e.target.value) })}
          style={{ width: '80px', accentColor: 'var(--green)' }}
        />
        <span style={{ fontSize: '10px', color: 'var(--green)', width: '36px' }}>{filters.minROI}%</span>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        <label style={{ fontSize: '10px', color: 'var(--text)' }}>Max Risk</label>
        <input
          type="range" min="0" max="100" step="5"
          value={filters.maxRisk}
          onChange={e => setFilters({ maxRisk: Number(e.target.value) })}
          style={{ width: '80px', accentColor: 'var(--red)' }}
        />
        <span style={{ fontSize: '10px', color: 'var(--red)', width: '28px' }}>{filters.maxRisk}</span>
      </div>

      <div style={{ display: 'flex', gap: '4px', marginLeft: 'auto' }}>
        {SORTS.map(s => (
          <button
            key={s.id}
            onClick={() => setFilters({ sort: s.id })}
            style={{
              padding: '4px 10px',
              fontSize: '10px',
              fontFamily: 'var(--mono)',
              color: filters.sort === s.id ? 'var(--text-bright)' : 'var(--text)',
              background: filters.sort === s.id ? 'var(--surface2)' : 'none',
              border: `1px solid ${filters.sort === s.id ? 'var(--border2)' : 'transparent'}`,
              borderRadius: '4px'
            }}
          >
            {s.label}
          </button>
        ))}
      </div>
    </div>
  )
}
