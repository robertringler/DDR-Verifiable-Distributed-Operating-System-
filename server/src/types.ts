export type SignalClass = 'HOT_OPPORTUNITY' | 'STRONG_SIGNAL' | 'WATCH' | 'LOW_OPPORTUNITY'

export interface SoldComp {
  price: number
  date: string
  title: string
}

export interface Listing {
  id: string
  source: 'ebay' | 'govdeals' | 'facebook'
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

export interface ROIResult {
  estResalePrice: number
  roi: number
  riskScore: number
  signalStrength: number
  classification: SignalClass
  soldComps: SoldComp[]
}
