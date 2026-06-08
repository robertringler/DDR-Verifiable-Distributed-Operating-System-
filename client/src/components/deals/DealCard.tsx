import { useState } from 'react'
import type { Listing } from '../../types'
import Badge from '../ui/Badge'
import SourceBadge from '../ui/SourceBadge'
import DealModal from './DealModal'
import { formatCurrency, formatROI, sigColor } from '../../lib/utils'
import { useFlipRadarStore } from '../../store/flipradarStore'

export default function DealCard({ listing }: { listing: Listing }) {
  const [open, setOpen] = useState(false)
  const { watchlist, addToWatchlist, removeFromWatchlist } = useFlipRadarStore()
  const inWatch = watchlist.some(w => w.id === listing.id)
  const roiColor = listing.roi >= 0 ? 'var(--green)' : 'var(--red)'

  return (
    <>
      <div
        className="animate-in"
        onClick={() => setOpen(true)}
        style={{
          background: 'var(--surface)',
          border: `1px solid var(--border)`,
          borderTop: `2px solid ${sigColor(listing.classification)}`,
          borderRadius: '8px',
          overflow: 'hidden',
          cursor: 'pointer',
          transition: 'border-color 0.15s, transform 0.15s',
          display: 'flex',
          flexDirection: 'column'
        }}
        onMouseEnter={e => (e.currentTarget.style.borderColor = sigColor(listing.classification))}
        onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}
      >
        <div style={{ position: 'relative', height: '160px', background: 'var(--surface2)', overflow: 'hidden' }}>
          {listing.images[0] ? (
            <img
              src={listing.images[0]}
              alt={listing.title}
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              onError={e => { (e.target as HTMLImageElement).style.display = 'none' }}
            />
          ) : (
            <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-dim)', fontSize: '11px' }}>
              No Image
            </div>
          )}
          <div style={{ position: 'absolute', top: '8px', left: '8px', display: 'flex', gap: '4px' }}>
            <Badge cls={listing.classification} />
            <SourceBadge source={listing.source} />
          </div>
          <button
            onClick={e => { e.stopPropagation(); inWatch ? removeFromWatchlist(listing.id) : addToWatchlist(listing) }}
            style={{
              position: 'absolute', top: '8px', right: '8px',
              width: '24px', height: '24px', borderRadius: '50%',
              background: inWatch ? 'var(--green)' : 'rgba(0,0,0,0.5)',
              border: '1px solid var(--border)',
              color: inWatch ? 'var(--bg)' : 'var(--text)',
              fontSize: '12px',
              display: 'flex', alignItems: 'center', justifyContent: 'center'
            }}
          >
            {inWatch ? '★' : '☆'}
          </button>
        </div>

        <div style={{ padding: '12px', display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
          <p style={{ fontSize: '12px', color: 'var(--text-bright)', lineHeight: 1.4, overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
            {listing.title}
          </p>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 'auto' }}>
            <div>
              <div style={{ fontSize: '18px', fontFamily: 'var(--display)', color: 'var(--text-bright)' }}>
                {formatCurrency(listing.buyPrice)}
              </div>
              <div style={{ fontSize: '10px', color: 'var(--text)' }}>
                Resale: {formatCurrency(listing.estResalePrice)}
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: '20px', fontFamily: 'var(--display)', color: roiColor }}>
                {formatROI(listing.roi)}
              </div>
              <div style={{ fontSize: '10px', color: 'var(--text)' }}>
                Risk: {listing.riskScore}
              </div>
            </div>
          </div>

          <div style={{ fontSize: '10px', color: 'var(--text)', display: 'flex', gap: '8px' }}>
            <span>{listing.condition}</span>
            <span style={{ color: 'var(--border2)' }}>|</span>
            <span>{listing.location}</span>
          </div>
        </div>
      </div>

      {open && <DealModal listing={listing} onClose={() => setOpen(false)} />}
    </>
  )
}
