import { useListings } from '../../hooks/useListings'
import FilterBar from '../layout/FilterBar'
import DealCard from '../deals/DealCard'

export default function Opportunities() {
  const { data: listings = [], isLoading } = useListings()

  return (
    <div>
      <FilterBar />
      <div style={{ padding: '24px' }}>
        {isLoading ? (
          <div style={{ color: 'var(--text)', fontSize: '12px' }}>Loading deals...</div>
        ) : listings.length === 0 ? (
          <div style={{ color: 'var(--text)', fontSize: '12px' }}>No deals match current filters.</div>
        ) : (
          <>
            <div style={{ fontSize: '11px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '14px' }}>
              {listings.length} DEALS FOUND
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '14px' }}>
              {listings.map(l => <DealCard key={l.id} listing={l} />)}
            </div>
          </>
        )}
      </div>
    </div>
  )
}
