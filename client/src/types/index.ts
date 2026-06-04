export type SignalClass = 'HOT_OPPORTUNITY' | 'STRONG_SIGNAL' | 'WATCH' | 'LOW_OPPORTUNITY'
export type Marketplace = 'ebay' | 'govdeals' | 'facebook'

export interface SoldComp {
  price: number
  date: string
  title: string
}

export interface Listing {
  id: string
  source: Marketplace
  title: string
  buyPrice: number
  estResalePrice: number
  roi: number
  riskScore: number
  signalStrength: number
  classification: SignalClass
  images: string[]
  listingUrl: string
  location: string
  condition: string
  category: string
  soldComps: SoldComp[]
  scrapedAt: string
}

export interface Stats {
  total: number
  avgROI: number
  avgRisk: number
  hotCount: number
  bySource: { ebay: number; govdeals: number; facebook: number }
  byCategory: Record<string, number>
  lastRefresh: string
}
