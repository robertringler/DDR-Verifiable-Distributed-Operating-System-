import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Listing } from '../types'

interface Filters {
  source: string
  minROI: number
  maxRisk: number
  sort: string
  category: string
}

interface PortfolioEntry {
  listing: Listing
  purchasedAt: number
  purchaseDate: string
}

interface FlipRadarStore {
  watchlist: Listing[]
  portfolio: PortfolioEntry[]
  filters: Filters
  selectedListing: Listing | null
  addToWatchlist: (l: Listing) => void
  removeFromWatchlist: (id: string) => void
  addToPortfolio: (l: Listing, purchasedAt: number) => void
  removeFromPortfolio: (id: string) => void
  setFilters: (f: Partial<Filters>) => void
  setSelectedListing: (l: Listing | null) => void
}

export const useFlipRadarStore = create<FlipRadarStore>()(
  persist(
    (set) => ({
      watchlist: [],
      portfolio: [],
      filters: { source: 'all', minROI: 0, maxRisk: 100, sort: 'roi', category: '' },
      selectedListing: null,
      addToWatchlist: (l) => set(s => ({ watchlist: s.watchlist.find(x => x.id === l.id) ? s.watchlist : [...s.watchlist, l] })),
      removeFromWatchlist: (id) => set(s => ({ watchlist: s.watchlist.filter(x => x.id !== id) })),
      addToPortfolio: (l, purchasedAt) => set(s => ({
        portfolio: [...s.portfolio, { listing: l, purchasedAt, purchaseDate: new Date().toISOString() }]
      })),
      removeFromPortfolio: (id) => set(s => ({ portfolio: s.portfolio.filter(x => x.listing.id !== id) })),
      setFilters: (f) => set(s => ({ filters: { ...s.filters, ...f } })),
      setSelectedListing: (l) => set({ selectedListing: l })
    }),
    { name: 'flipradar-store' }
  )
)
