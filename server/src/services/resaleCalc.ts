import { findCompletedItems } from './ebay'
import type { ROIResult } from '../types'

function stdDev(nums: number[]): number {
  if (nums.length < 2) return 0
  const mean = nums.reduce((a, b) => a + b, 0) / nums.length
  const variance = nums.reduce((s, n) => s + Math.pow(n - mean, 2), 0) / nums.length
  return Math.sqrt(variance)
}

export async function calculateROI(title: string, buyPrice: number): Promise<ROIResult> {
  const soldComps = await findCompletedItems(title, 10)
  const prices = soldComps.map(c => c.price).filter(p => p > 0).sort((a, b) => a - b)

  const median = prices.length > 0
    ? prices[Math.floor(prices.length / 2)]
    : buyPrice * 1.3

  const roi = ((median - buyPrice) / buyPrice) * 100
  const sd = stdDev(prices)
  const variance = median > 0 ? sd / median : 0.5
  const riskScore = Math.min(100, Math.round(variance * 200 + 10))
  const signalStrength = Math.min(1, Math.max(0, roi / 500 * 0.5 + (1 - variance) * 0.5))

  const classification =
    signalStrength > 0.75 ? 'HOT_OPPORTUNITY' :
    signalStrength > 0.55 ? 'STRONG_SIGNAL' :
    signalStrength > 0.35 ? 'WATCH' : 'LOW_OPPORTUNITY'

  return { estResalePrice: median, roi, riskScore, signalStrength, classification, soldComps }
}
