import { useListings, useStats } from '../../hooks/useListings'
import MetricTile from '../dashboard/MetricTile'
import SignalFeed from '../dashboard/SignalFeed'
import DealCard from '../deals/DealCard'
import { formatROI } from '../../lib/utils'

export default function Dashboard() {
  const { data: listings = [], isLoading } = useListings()
  const { data: stats } = useStats()
  const top = listings.slice(0, 12)

  return (
    <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px' }}>
        <MetricTile label="Total Deals" value={stats?.total ?? '—'} sub="across all sources" />
        <MetricTile label="Avg ROI" value={stats ? formatROI(stats.avgROI) : '—'} accent="var(--green)" sub="estimated resale margin" />
        <MetricTile label="Hot Signals" value={stats?.hotCount ?? '—'} accent="var(--gold)" sub="ROI &gt; 75% signal strength" />
        <MetricTile label="Avg Risk" value={stats?.avgRisk ?? '—'} accent="var(--blue)" sub="lower is safer" />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 280px', gap: '20px', alignItems: 'start' }}>
        <div>
          <div style={{ fontSize: '11px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '14px' }}>TOP DEALS</div>
          {isLoading ? (
            <div style={{ color: 'var(--text)', fontSize: '12px', padding: '20px' }}>Fetching live listings...</div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '14px' }}>
              {top.map(l => <DealCard key={l.id} listing={l} />)}
            </div>
          )}
        </div>
        <SignalFeed />
      </div>
    </div>
  )
}
