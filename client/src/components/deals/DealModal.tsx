import { useEffect, useState } from 'react'
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'
import type { Listing } from '../../types'
import Badge from '../ui/Badge'
import SourceBadge from '../ui/SourceBadge'
import { formatCurrency, formatROI } from '../../lib/utils'
import { useFlipRadarStore } from '../../store/flipradarStore'

export default function DealModal({ listing, onClose }: { listing: Listing; onClose: () => void }) {
  const [imgIdx, setImgIdx] = useState(0)
  const [portfolioPrice, setPortfolioPrice] = useState(String(listing.buyPrice))
  const { watchlist, addToWatchlist, removeFromWatchlist, portfolio, addToPortfolio } = useFlipRadarStore()
  const inWatch = watchlist.some(w => w.id === listing.id)
  const inPortfolio = portfolio.some(e => e.listing.id === listing.id)

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    document.addEventListener('keydown', esc)
    return () => document.removeEventListener('keydown', esc)
  }, [onClose])

  const compData = listing.soldComps.map((c, i) => ({ i: i + 1, price: c.price }))

  return (
    <div
      style={{
        position: 'fixed', inset: 0, zIndex: 200,
        background: 'rgba(7,11,15,0.85)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '24px'
      }}
      onClick={onClose}
    >
      <div
        onClick={e => e.stopPropagation()}
        style={{
          background: 'var(--surface)',
          border: '1px solid var(--border2)',
          borderRadius: '10px',
          width: '100%',
          maxWidth: '720px',
          maxHeight: '90vh',
          overflow: 'auto',
          display: 'flex',
          flexDirection: 'column',
          position: 'relative'
        }}
      >
        <button
          onClick={onClose}
          style={{
            position: 'absolute', top: '10px', right: '12px', zIndex: 10,
            width: '24px', height: '24px', borderRadius: '50%',
            background: 'var(--surface2)', border: '1px solid var(--border)',
            color: 'var(--text)', fontSize: '14px',
            display: 'flex', alignItems: 'center', justifyContent: 'center'
          }}
        >
          ×
        </button>

        <div style={{ display: 'flex', gap: '0', minHeight: '280px' }}>
          <div style={{ width: '320px', flexShrink: 0, background: 'var(--surface2)', position: 'relative' }}>
            {listing.images[imgIdx] ? (
              <img src={listing.images[imgIdx]} alt={listing.title}
                style={{ width: '100%', height: '100%', objectFit: 'cover', minHeight: '280px' }} />
            ) : (
              <div style={{ height: '280px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-dim)', fontSize: '12px' }}>No Image</div>
            )}
            {listing.images.length > 1 && (
              <div style={{ position: 'absolute', bottom: '8px', left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: '4px' }}>
                {listing.images.map((_, i) => (
                  <button key={i} onClick={() => setImgIdx(i)}
                    style={{ width: 6, height: 6, borderRadius: '50%', background: i === imgIdx ? 'var(--green)' : 'var(--border2)', border: 'none' }} />
                ))}
              </div>
            )}
          </div>

          <div style={{ flex: 1, padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', gap: '6px' }}>
              <Badge cls={listing.classification} />
              <SourceBadge source={listing.source} />
            </div>
            <h2 style={{ fontSize: '13px', color: 'var(--text-bright)', lineHeight: 1.4, paddingRight: '30px' }}>{listing.title}</h2>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              {[
                { label: 'Buy Price', value: formatCurrency(listing.buyPrice), color: 'var(--text-bright)' },
                { label: 'Est. Resale', value: formatCurrency(listing.estResalePrice), color: 'var(--green)' },
                { label: 'ROI', value: formatROI(listing.roi), color: listing.roi >= 0 ? 'var(--green)' : 'var(--red)' },
                { label: 'Risk Score', value: listing.riskScore, color: listing.riskScore < 40 ? 'var(--green)' : listing.riskScore < 70 ? 'var(--gold)' : 'var(--red)' }
              ].map(m => (
                <div key={m.label} style={{ background: 'var(--surface2)', borderRadius: '6px', padding: '10px' }}>
                  <div style={{ fontSize: '9px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '4px' }}>{m.label}</div>
                  <div style={{ fontSize: '20px', fontFamily: 'var(--display)', color: m.color }}>{m.value}</div>
                </div>
              ))}
            </div>

            <div style={{ fontSize: '11px', color: 'var(--text)', display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
              <span>Condition: {listing.condition}</span>
              <span>Location: {listing.location}</span>
              <span>Category: {listing.category}</span>
            </div>

            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', marginTop: 'auto' }}>
              <a
                href={listing.listingUrl}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  flex: 1, padding: '7px', textAlign: 'center',
                  background: 'var(--green)', color: 'var(--bg)',
                  borderRadius: '5px', fontSize: '11px', fontWeight: 600, letterSpacing: '0.05em'
                }}
              >
                View Listing ↗
              </a>
              <button
                onClick={() => inWatch ? removeFromWatchlist(listing.id) : addToWatchlist(listing)}
                style={{
                  padding: '7px 12px',
                  background: inWatch ? 'rgba(16,185,129,0.1)' : 'var(--surface2)',
                  border: `1px solid ${inWatch ? 'var(--green)' : 'var(--border)'}`,
                  color: inWatch ? 'var(--green)' : 'var(--text)',
                  borderRadius: '5px', fontSize: '11px'
                }}
              >
                {inWatch ? '★ Saved' : '☆ Watch'}
              </button>
            </div>
          </div>
        </div>

        {compData.length > 0 && (
          <div style={{ padding: '14px 20px', borderTop: '1px solid var(--border)' }}>
            <div style={{ fontSize: '10px', color: 'var(--text)', letterSpacing: '0.08em', marginBottom: '10px' }}>
              SOLD COMPS ({compData.length} recent eBay sales)
            </div>
            <ResponsiveContainer width="100%" height={80}>
              <AreaChart data={compData} margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="compGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="i" hide />
                <YAxis hide domain={['auto', 'auto']} />
                <Tooltip
                  contentStyle={{ background: 'var(--surface2)', border: '1px solid var(--border)', fontSize: '10px' }}
                  formatter={(v: number) => [formatCurrency(v), 'Sold Price']}
                />
                <Area type="monotone" dataKey="price" stroke="#10B981" strokeWidth={1.5} fill="url(#compGrad)" dot={false} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        )}

        <div style={{ padding: '12px 20px', borderTop: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span style={{ fontSize: '10px', color: 'var(--text)' }}>I paid</span>
          <input
            type="number"
            value={portfolioPrice}
            onChange={e => setPortfolioPrice(e.target.value)}
            style={{
              width: '90px', padding: '5px 8px',
              background: 'var(--surface2)', border: '1px solid var(--border)',
              borderRadius: '4px', color: 'var(--text-bright)', fontSize: '12px',
              fontFamily: 'var(--mono)'
            }}
          />
          <button
            onClick={() => {
              const price = parseFloat(portfolioPrice)
              if (price > 0 && !inPortfolio) addToPortfolio(listing, price)
            }}
            disabled={inPortfolio}
            style={{
              padding: '5px 12px', fontSize: '10px', fontWeight: 600, letterSpacing: '0.05em',
              background: inPortfolio ? 'rgba(16,185,129,0.1)' : 'var(--surface2)',
              border: `1px solid ${inPortfolio ? 'var(--green)' : 'var(--border)'}`,
              color: inPortfolio ? 'var(--green)' : 'var(--text)',
              borderRadius: '4px'
            }}
          >
            {inPortfolio ? '✓ In Portfolio' : 'Add to Portfolio'}
          </button>
        </div>
      </div>
    </div>
  )
}
