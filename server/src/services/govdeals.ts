import axios from 'axios'
import { calculateROI } from './resaleCalc'
import type { Listing } from '../types'

interface ApifyItem {
  title?: string
  currentBid?: number
  price?: number
  imageUrl?: string
  images?: string[]
  url?: string
  location?: string
  auctionEndDate?: string
  category?: string
}

export async function fetchGovDealsListings(): Promise<Listing[]> {
  const apiKey = process.env.APIFY_API_KEY
  if (!apiKey) {
    console.warn('[govdeals] APIFY_API_KEY not set — skipping GovDeals fetch')
    return []
  }

  const listings: Listing[] = []

  try {
    const runRes = await axios.post(
      `https://api.apify.com/v2/acts/parseforge~govdeals-scraper/runs`,
      { maxItems: 50, category: 'Electronics' },
      {
        headers: { Authorization: `Bearer ${apiKey}` },
        params: { token: apiKey },
        timeout: 60000
      }
    )

    const runId: string = runRes.data?.data?.id
    if (!runId) return []

    // Poll for completion (max 90s)
    let attempts = 0
    let items: ApifyItem[] = []
    while (attempts < 18) {
      await new Promise(r => setTimeout(r, 5000))
      const statusRes = await axios.get(
        `https://api.apify.com/v2/actor-runs/${runId}`,
        { params: { token: apiKey }, timeout: 10000 }
      )
      const status: string = statusRes.data?.data?.status
      if (status === 'SUCCEEDED') {
        const dataRes = await axios.get(
          `https://api.apify.com/v2/actor-runs/${runId}/dataset/items`,
          { params: { token: apiKey }, timeout: 15000 }
        )
        items = dataRes.data || []
        break
      }
      if (status === 'FAILED' || status === 'ABORTED') break
      attempts++
    }

    for (const item of items) {
      const title = item.title || ''
      const buyPrice = item.currentBid || item.price || 0
      if (!title || buyPrice <= 0) continue

      const roi = await calculateROI(title, buyPrice)
      const images = item.images || (item.imageUrl ? [item.imageUrl] : [])

      listings.push({
        id: `govdeals-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        source: 'govdeals',
        title,
        buyPrice,
        estResalePrice: roi.estResalePrice,
        roi: roi.roi,
        riskScore: roi.riskScore,
        signalStrength: roi.signalStrength,
        classification: roi.classification,
        images,
        listingUrl: item.url || '',
        location: item.location || 'Government Auction',
        condition: 'Used',
        category: item.category || 'Electronics',
        soldComps: roi.soldComps,
        scrapedAt: new Date().toISOString()
      })
    }
  } catch (e) {
    console.error('[govdeals] error:', e)
  }

  return listings
}
