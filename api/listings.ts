import type { VercelRequest, VercelResponse } from '@vercel/node'
import { fetchEbayListings } from '../server/src/services/ebay'
import { fetchGovDealsListings } from '../server/src/services/govdeals'
import { fetchFacebookListings } from '../server/src/services/facebook'
import { getCache, setCache } from '../server/src/cache'
import type { Listing } from '../server/src/types'

const QUERIES = [
  'cisco switch', 'fluke multimeter', 'tektronix oscilloscope',
  'rolex watch', 'jordan sneakers', 'milwaukee tools',
  'ipad', 'macbook', 'samsung galaxy'
]

async function getSource(source: string): Promise<Listing[]> {
  const key = `listings:${source}`
  const cached = getCache<Listing[]>(key)
  if (cached) return cached

  let results: Listing[] = []
  if (source === 'ebay') results = await fetchEbayListings(QUERIES)
  else if (source === 'govdeals') results = await fetchGovDealsListings()
  else if (source === 'facebook') results = await fetchFacebookListings()

  setCache(key, results)
  return results
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  try {
    const source = (req.query.source as string) || 'all'
    const minROI = parseFloat((req.query.minROI as string) || '0')
    const maxRisk = parseFloat((req.query.maxRisk as string) || '100')
    const sort = (req.query.sort as string) || 'roi'
    const category = req.query.category as string | undefined

    let listings: Listing[] = []
    if (source === 'all') {
      const settled = await Promise.allSettled([
        getSource('ebay'), getSource('govdeals'), getSource('facebook')
      ])
      for (const r of settled) if (r.status === 'fulfilled') listings.push(...r.value)
    } else {
      listings = await getSource(source)
    }

    listings = listings.filter(l => l.roi >= minROI && l.riskScore <= maxRisk)
    if (category) listings = listings.filter(l => l.category === category)

    listings.sort((a, b) => {
      if (sort === 'roi') return b.roi - a.roi
      if (sort === 'price') return a.buyPrice - b.buyPrice
      if (sort === 'risk') return a.riskScore - b.riskScore
      return new Date(b.scrapedAt).getTime() - new Date(a.scrapedAt).getTime()
    })

    res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600')
    res.status(200).json(listings)
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Failed to fetch listings' })
  }
}
