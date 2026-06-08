import axios from 'axios'
import { calculateROI } from './resaleCalc'
import type { Listing, SoldComp } from '../types'

const BASE = 'https://svcs.ebay.com/services/search/FindingService/v1'

function categoryFromTitle(title: string): string {
  const t = title.toLowerCase()
  if (/watch|rolex|omega|seiko/.test(t)) return 'Watches'
  if (/jordan|nike|sneaker|yeezy/.test(t)) return 'Sneakers'
  if (/macbook|laptop|computer/.test(t)) return 'Computers'
  if (/ipad|tablet/.test(t)) return 'Tablets'
  if (/iphone|samsung|galaxy|phone/.test(t)) return 'Phones'
  if (/golf|driver|iron|putter/.test(t)) return 'Golf'
  if (/generator/.test(t)) return 'Power'
  if (/milwaukee|dewalt|makita|tool/.test(t)) return 'Tools'
  return 'Electronics'
}

export async function findCompletedItems(keyword: string, limit = 10): Promise<SoldComp[]> {
  const appId = process.env.EBAY_APP_ID
  if (!appId) return []
  try {
    const { data } = await axios.get(BASE, {
      params: {
        'OPERATION-NAME': 'findCompletedItems',
        'SECURITY-APPNAME': appId,
        'RESPONSE-DATA-FORMAT': 'JSON',
        'keywords': keyword,
        'itemFilter(0).name': 'SoldItemsOnly',
        'itemFilter(0).value': 'true',
        'paginationInput.entriesPerPage': limit
      },
      timeout: 10000
    })
    const items = data?.findCompletedItemsResponse?.[0]?.searchResult?.[0]?.item || []
    return items.map((item: Record<string, unknown>) => ({
      price: parseFloat((item.sellingStatus as Record<string, unknown>[])?.[0]?.convertedCurrentPrice?.[0]?.['__value__'] as string || '0'),
      date: (item.listingInfo as Record<string, unknown>[])?.[0]?.endTime?.[0] as string || new Date().toISOString(),
      title: (item.title as string[])?.[0] || ''
    }))
  } catch {
    return []
  }
}

export async function fetchEbayListings(queries: string[]): Promise<Listing[]> {
  const appId = process.env.EBAY_APP_ID
  if (!appId) {
    console.warn('[ebay] EBAY_APP_ID not set — skipping eBay fetch')
    return []
  }

  const listings: Listing[] = []

  for (const query of queries) {
    try {
      const { data } = await axios.get(BASE, {
        params: {
          'OPERATION-NAME': 'findItemsByKeywords',
          'SECURITY-APPNAME': appId,
          'RESPONSE-DATA-FORMAT': 'JSON',
          'keywords': query,
          'itemFilter(0).name': 'ListingType',
          'itemFilter(0).value': 'FixedPrice',
          'sortOrder': 'PricePlusShippingLowest',
          'paginationInput.entriesPerPage': '10'
        },
        timeout: 10000
      })

      const items = data?.findItemsByKeywordsResponse?.[0]?.searchResult?.[0]?.item || []

      for (const item of items.slice(0, 5)) {
        const title: string = item.title?.[0] || ''
        const buyPrice = parseFloat(item.sellingStatus?.[0]?.convertedCurrentPrice?.[0]?.['__value__'] || '0')
        if (!title || buyPrice <= 0) continue

        const roi = await calculateROI(title, buyPrice)
        const imageUrl: string = item.galleryURL?.[0] || ''
        const listingUrl: string = item.viewItemURL?.[0] || ''
        const condition: string = item.condition?.[0]?.conditionDisplayName?.[0] || 'Unknown'
        const location: string = item.location?.[0] || 'Unknown'
        const itemId: string = item.itemId?.[0] || Math.random().toString(36).slice(2)

        listings.push({
          id: `ebay-${itemId}`,
          source: 'ebay',
          title,
          buyPrice,
          estResalePrice: roi.estResalePrice,
          roi: roi.roi,
          riskScore: roi.riskScore,
          signalStrength: roi.signalStrength,
          classification: roi.classification,
          images: imageUrl ? [imageUrl.replace('s-l140', 's-l500')] : [],
          listingUrl,
          location,
          condition,
          category: categoryFromTitle(title),
          soldComps: roi.soldComps,
          scrapedAt: new Date().toISOString()
        })
      }
    } catch (e) {
      console.error(`[ebay] error for query "${query}":`, e)
    }
  }

  return listings
}
