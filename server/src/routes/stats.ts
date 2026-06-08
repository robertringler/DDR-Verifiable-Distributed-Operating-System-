import { Router, Request, Response } from 'express'
import { getCache } from '../cache'
import type { Listing } from '../types'

const router = Router()

router.get('/', (_req: Request, res: Response) => {
  const ebay = getCache<Listing[]>('listings:ebay') || []
  const gov = getCache<Listing[]>('listings:govdeals') || []
  const fb = getCache<Listing[]>('listings:facebook') || []
  const all = [...ebay, ...gov, ...fb]

  const lastRefresh = getCache<string>('stats:lastRefresh') || new Date().toISOString()

  const avgROI = all.length ? all.reduce((s, l) => s + l.roi, 0) / all.length : 0
  const avgRisk = all.length ? all.reduce((s, l) => s + l.riskScore, 0) / all.length : 0
  const hotCount = all.filter(l => l.classification === 'HOT_OPPORTUNITY').length

  const bySource = {
    ebay: ebay.length,
    govdeals: gov.length,
    facebook: fb.length
  }

  const byCategory: Record<string, number> = {}
  all.forEach(l => {
    byCategory[l.category] = (byCategory[l.category] || 0) + 1
  })

  res.json({
    total: all.length,
    avgROI: Math.round(avgROI * 10) / 10,
    avgRisk: Math.round(avgRisk),
    hotCount,
    bySource,
    byCategory,
    lastRefresh
  })
})

export default router
