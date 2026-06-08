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

async function getSource(source: string, fn: () => Promise<Listing[]>): Promise<Listing[]> {
  const key = `listings:${source}`
  const cached = getCache<Listing[]>(key)
  if (cached) return cached
  const results = await fn()
  setCache(key, results)
  return results
}

export default async function handler(_req: VercelRequest, res: VercelResponse) {
  const settled = await Promise.allSettled([
    getSource('ebay', () => fetchEbayListings(QUERIES)),
    getSource('govdeals', fetchGovDealsListings),
    getSource('facebook', fetchFacebookListings)
  ])
  const ebay = settled[0].status === 'fulfilled' ? settled[0].value : []
  const gov = settled[1].status === 'fulfilled' ? settled[1].value : []
  const fb = settled[2].status === 'fulfilled' ? settled[2].value : []
  const all = [...ebay, ...gov, ...fb]

  const avgROI = all.length ? all.reduce((s, l) => s + l.roi, 0) / all.length : 0
  const avgRisk = all.length ? all.reduce((s, l) => s + l.riskScore, 0) / all.length : 0
  const hotCount = all.filter(l => l.classification === 'HOT_OPPORTUNITY').length
  const byCategory: Record<string, number> = {}
  all.forEach(l => { byCategory[l.category] = (byCategory[l.category] || 0) + 1 })

  res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600')
  res.status(200).json({
    total: all.length,
    avgROI: Math.round(avgROI * 10) / 10,
    avgRisk: Math.round(avgRisk),
    hotCount,
    bySource: { ebay: ebay.length, govdeals: gov.length, facebook: fb.length },
    byCategory,
    lastRefresh: new Date().toISOString()
  })
}
