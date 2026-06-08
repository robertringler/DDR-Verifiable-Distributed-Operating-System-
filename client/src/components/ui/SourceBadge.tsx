import type { Marketplace } from '../../types'

const CONFIG: Record<Marketplace, { label: string; color: string; bg: string }> = {
  ebay: { label: 'eBay', color: '#3B82F6', bg: 'rgba(59,130,246,0.12)' },
  govdeals: { label: 'GovDeals', color: '#C8A24A', bg: 'rgba(200,162,74,0.12)' },
  facebook: { label: 'Facebook', color: '#8B5CF6', bg: 'rgba(139,92,246,0.12)' }
}

export default function SourceBadge({ source }: { source: Marketplace }) {
  const cfg = CONFIG[source]
  return (
    <span style={{
      fontSize: '9px',
      fontWeight: 600,
      letterSpacing: '0.05em',
      color: cfg.color,
      background: cfg.bg,
      border: `1px solid ${cfg.color}30`,
      borderRadius: '3px',
      padding: '2px 6px'
    }}>
      {cfg.label}
    </span>
  )
}
