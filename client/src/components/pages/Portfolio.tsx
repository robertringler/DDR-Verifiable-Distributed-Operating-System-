import { useState } from 'react'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'
import { useFlipRadarStore } from '../../store/flipradarStore'
import { formatCurrency } from '../../lib/utils'

export default function Portfolio() {
  const { portfolio, removeFromPortfolio } = useFlipRadarStore()
  const [buyInput, setBuyInput] = useState<Record<string, string>>({})

  const totalCost = portfolio.reduce((s, e) => s + e.purchasedAt, 0)
  const totalResale = portfolio.reduce((s, e) => s + e.listing.estResalePrice, 0)
  const pl = totalResale - totalCost

  const chartData = portfolio.map((e, i) => ({
    i: i + 1,
    value: portfolio.slice(0, i + 1).reduce((s, x) => s + x.listing.estResalePrice, 0)
  }))

  return (
    <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: '12px' }}>
        {[
          { label: 'Total Cost', value: formatCurrency(totalCost), color: 'var(--text-bright)' },
          { label: 'Est. Resale', value: formatCurrency(totalResale), color: 'var(--green)' },
          { label: 'Net P&L', value: formatCurrency(pl), color: pl >= 0 ? 'var(--green)' : 'var(--red)' },
          { label: 'Holdings', value: portfolio.length, color: 'var(--blue)' }
        ].map(m => (
          <div key={m.label} style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '14px' }}>
            <div style={{ fontSize: '10px', color: 'var(--text)', marginBottom: '4px', letterSpacing: '0.08em' }}>{m.label}</div>
            <div style={{ fontSize: '22px', fontFamily: 'var(--display)', color: m.color }}>{m.value}</div>
          </div>
        ))}
      </div>

      {chartData.length > 1 && (
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '16px' }}>
          <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '10px' }}>PORTFOLIO VALUE</div>
          <ResponsiveContainer width="100%" height={120}>
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="pvGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid stroke="var(--border)" strokeDasharray="3 3" />
              <XAxis dataKey="i" hide />
              <YAxis hide />
              <Tooltip contentStyle={{ background: 'var(--surface2)', border: '1px solid var(--border)', fontSize: '10px' }}
                formatter={(v: number) => [formatCurrency(v), 'Value']} />
              <Area type="monotone" dataKey="value" stroke="#10B981" strokeWidth={1.5} fill="url(#pvGrad)" dot={false} />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      )}

      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        {portfolio.length === 0 ? (
          <div style={{ color: 'var(--text)', fontSize: '12px', padding: '40px', textAlign: 'center', border: '1px dashed var(--border)', borderRadius: '8px' }}>
            No portfolio entries yet. Open a deal modal and add it to your portfolio.
          </div>
        ) : portfolio.map(e => (
          <div key={e.listing.id} style={{
            background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '6px',
            padding: '12px 16px', display: 'flex', alignItems: 'center', gap: '12px'
          }}>
            {e.listing.images[0] && (
              <img src={e.listing.images[0]} alt="" style={{ width: 48, height: 48, borderRadius: 4, objectFit: 'cover', flexShrink: 0 }} />
            )}
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: '12px', color: 'var(--text-bright)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{e.listing.title}</div>
              <div style={{ fontSize: '10px', color: 'var(--text)', marginTop: '2px' }}>
                Paid {formatCurrency(e.purchasedAt)} → Est. {formatCurrency(e.listing.estResalePrice)}
              </div>
            </div>
            <div style={{ fontSize: '16px', fontFamily: 'var(--display)', color: e.listing.estResalePrice >= e.purchasedAt ? 'var(--green)' : 'var(--red)' }}>
              {formatCurrency(e.listing.estResalePrice - e.purchasedAt)}
            </div>
            <button
              onClick={() => removeFromPortfolio(e.listing.id)}
              style={{ padding: '4px 8px', fontSize: '10px', color: 'var(--red)', border: '1px solid var(--red)', borderRadius: '4px', background: 'none' }}
            >
              Remove
            </button>
          </div>
        ))}
      </div>

      {portfolio.length > 0 && (
        <div style={{ fontSize: '11px', color: 'var(--text)' }}>
          Tip: Add deals to your portfolio from the deal modal by clicking "Add to Portfolio".
        </div>
      )}
    </div>
  )
}
