import {
  ScatterChart, Scatter, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell, Legend
} from 'recharts'
import { useListings, useStats } from '../../hooks/useListings'
import { formatCurrency } from '../../lib/utils'

const PIE_COLORS = ['#3B82F6', '#C8A24A', '#8B5CF6']

export default function Analytics() {
  const { data: listings = [] } = useListings()
  const { data: stats } = useStats()

  const scatterData = listings.map(l => ({ roi: Math.round(l.roi), risk: l.riskScore, price: l.buyPrice, title: l.title }))

  const catData = stats?.byCategory
    ? Object.entries(stats.byCategory).map(([name, count]) => ({ name, count }))
    : []

  const pieData = stats?.bySource
    ? [
        { name: 'eBay', value: stats.bySource.ebay },
        { name: 'GovDeals', value: stats.bySource.govdeals },
        { name: 'Facebook', value: stats.bySource.facebook }
      ].filter(d => d.value > 0)
    : []

  const sigData = [
    { name: 'HOT', count: listings.filter(l => l.classification === 'HOT_OPPORTUNITY').length, color: '#10B981' },
    { name: 'STRONG', count: listings.filter(l => l.classification === 'STRONG_SIGNAL').length, color: '#C8A24A' },
    { name: 'WATCH', count: listings.filter(l => l.classification === 'WATCH').length, color: '#3B82F6' },
    { name: 'LOW', count: listings.filter(l => l.classification === 'LOW_OPPORTUNITY').length, color: '#94A3B8' }
  ]

  const tt = { contentStyle: { background: 'var(--surface2)', border: '1px solid var(--border)', fontSize: '11px', color: 'var(--text-bright)' } }

  return (
    <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '16px' }}>
          <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '12px' }}>ROI vs RISK</div>
          <ResponsiveContainer width="100%" height={220}>
            <ScatterChart>
              <CartesianGrid stroke="var(--border)" strokeDasharray="3 3" />
              <XAxis dataKey="risk" name="Risk" tick={{ fontSize: 10, fill: 'var(--text)' }} label={{ value: 'Risk', position: 'insideBottom', fill: 'var(--text)', fontSize: 10 }} />
              <YAxis dataKey="roi" name="ROI %" tick={{ fontSize: 10, fill: 'var(--text)' }} />
              <Tooltip {...tt} cursor={{ strokeDasharray: '3 3' }}
                content={({ payload }) => payload?.[0] ? (
                  <div style={{ background: 'var(--surface2)', border: '1px solid var(--border)', padding: '8px', fontSize: '10px' }}>
                    <div style={{ color: 'var(--text-bright)', marginBottom: '4px' }}>{payload[0].payload.title?.slice(0, 40)}</div>
                    <div>ROI: {payload[0].payload.roi}% | Risk: {payload[0].payload.risk}</div>
                    <div>Price: {formatCurrency(payload[0].payload.price)}</div>
                  </div>
                ) : null}
              />
              <Scatter data={scatterData} fill="#10B981" fillOpacity={0.7} />
            </ScatterChart>
          </ResponsiveContainer>
        </div>

        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '16px' }}>
          <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '12px' }}>DEALS BY CATEGORY</div>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={catData} layout="vertical" margin={{ left: 10 }}>
              <CartesianGrid stroke="var(--border)" strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 10, fill: 'var(--text)' }} />
              <YAxis dataKey="name" type="category" tick={{ fontSize: 10, fill: 'var(--text)' }} width={70} />
              <Tooltip {...tt} />
              <Bar dataKey="count" fill="#3B82F6" radius={[0, 3, 3, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '16px' }}>
          <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '12px' }}>SOURCE DISTRIBUTION</div>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie data={pieData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={70} label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                labelLine={{ stroke: 'var(--text)' }}
              >
                {pieData.map((_, i) => <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />)}
              </Pie>
              <Tooltip {...tt} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '16px' }}>
          <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '16px' }}>SIGNAL DISTRIBUTION</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {sigData.map(s => (
              <div key={s.name} style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ width: '50px', fontSize: '10px', color: s.color, fontWeight: 600 }}>{s.name}</span>
                <div style={{ flex: 1, height: '8px', background: 'var(--surface2)', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ height: '100%', background: s.color, borderRadius: '4px',
                    width: listings.length ? `${(s.count / listings.length) * 100}%` : '0%', transition: 'width 0.5s' }} />
                </div>
                <span style={{ width: '30px', fontSize: '10px', color: 'var(--text)', textAlign: 'right' }}>{s.count}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
