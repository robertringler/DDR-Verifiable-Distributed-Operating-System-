import { Router, Request, Response } from 'express'
import { getCache } from '../cache'
import { fetchEbayListings } from '../services/ebay'
import { fetchGovDealsListings } from '../services/govdeals'
import { fetchFacebookListings } from '../services/facebook'
import { setCache } from '../cache'
import type { Listing } from '../types'

const router = Router()

const QUERIES = [
  'cisco switch', 'fluke multimeter', 'tektronix oscilloscope',
  'rolex watch', 'jordan sneakers', 'milwaukee tools',
  'ipad', 'macbook', 'samsung galaxy'
]

async function getSource(source: string): Promise<Listing[]> {
  const cacheKey = `listings:${source}`
  const cached = getCache<Listing[]>(cacheKey)
  if (cached) return cached

  let results: Listing[] = []
  if (source === 'ebay') results = await fetchEbayListings(QUERIES)
  else if (source === 'govdeals') results = await fetchGovDealsListings()
  else if (source === 'facebook') results = await fetchFacebookListings()

  setCache(cacheKey, results)
  return results
}

router.get('/', async (req: Request, res: Response) => {
  try {
    const source = (req.query.source as string) || 'all'
    const minROI = parseFloat((req.query.minROI as string) || '0')
    const maxRisk = parseFloat((req.query.maxRisk as string) || '100')
    const sort = (req.query.sort as string) || 'roi'
    const category = req.query.category as string | undefined

    let listings: Listing[] = []

    if (source === 'all') {
      const [ebay, gov, fb] = await Promise.allSettled([
        getSource('ebay'),
        getSource('govdeals'),
        getSource('facebook')
      ])
      if (ebay.status === 'fulfilled') listings.push(...ebay.value)
      if (gov.status === 'fulfilled') listings.push(...gov.value)
      if (fb.status === 'fulfilled') listings.push(...fb.value)
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

    res.json(listings)
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Failed to fetch listings' })
  }
})

router.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params
  const [ebay, gov, fb] = await Promise.allSettled([
    getSource('ebay'),
    getSource('govdeals'),
    getSource('facebook')
  ])
  const all: Listing[] = []
  if (ebay.status === 'fulfilled') all.push(...ebay.value)
  if (gov.status === 'fulfilled') all.push(...gov.value)
  if (fb.status === 'fulfilled') all.push(...fb.value)

  const found = all.find(l => l.id === id)
  if (!found) return res.status(404).json({ error: 'Not found' })
  res.json(found)
})

export default router
