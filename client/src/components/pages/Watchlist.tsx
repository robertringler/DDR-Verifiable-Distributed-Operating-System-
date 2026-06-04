import { useFlipRadarStore } from '../../store/flipradarStore'
import DealCard from '../deals/DealCard'

export default function Watchlist() {
  const { watchlist } = useFlipRadarStore()

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ fontSize: '11px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '14px' }}>
        WATCHLIST — {watchlist.length} SAVED
      </div>
      {watchlist.length === 0 ? (
        <div style={{ color: 'var(--text)', fontSize: '12px', padding: '40px', textAlign: 'center', border: '1px dashed var(--border)', borderRadius: '8px' }}>
          No saved deals yet. Click ☆ on any deal card to save it here.
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '14px' }}>
          {watchlist.map(l => <DealCard key={l.id} listing={l} />)}
        </div>
      )}
    </div>
  )
}
