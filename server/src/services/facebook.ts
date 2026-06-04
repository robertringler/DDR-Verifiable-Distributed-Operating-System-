import type { Listing } from '../types'
import { calculateROI } from './resaleCalc'

let puppeteerExtra: typeof import('puppeteer-extra') | null = null

async function getPuppeteer() {
  if (puppeteerExtra) return puppeteerExtra
  try {
    const pe = await import('puppeteer-extra')
    const stealth = await import('puppeteer-extra-plugin-stealth')
    pe.default.use(stealth.default())
    puppeteerExtra = pe.default
    return puppeteerExtra
  } catch {
    return null
  }
}

interface FBItem {
  title: string
  price: number
  image: string
  location: string
  url: string
}

async function scrapeFacebook(): Promise<FBItem[]> {
  const pe = await getPuppeteer()
  if (!pe) return []

  const browser = await (pe as unknown as { launch: (opts: unknown) => Promise<{ newPage: () => Promise<unknown> }> }).launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  })

  try {
    const page = await (browser as { newPage: () => Promise<unknown> }).newPage() as {
      goto: (url: string, opts: unknown) => Promise<unknown>
      evaluate: <T>(fn: () => T) => Promise<T>
    }
    await page.goto('https://www.facebook.com/marketplace/category/electronics', {
      waitUntil: 'networkidle2',
      timeout: 30000
    })

    const items = await page.evaluate(() => {
      const cards = Array.from(document.querySelectorAll('[data-testid="marketplace_feed_item"], [class*="x9f619"]')).slice(0, 20)
      return cards.map(card => {
        const title = card.querySelector('[data-testid="marketplace_listing_item_title"], span')?.textContent?.trim() || ''
        const priceText = card.querySelector('[data-testid="marketplace_listing_item_price"], span')?.textContent || '0'
        const price = parseFloat(priceText.replace(/[^0-9.]/g, '')) || 0
        const image = (card.querySelector('img') as HTMLImageElement)?.src || ''
        const location = card.querySelector('[data-testid="marketplace_listing_item_location"]')?.textContent?.trim() || ''
        const href = (card.querySelector('a') as HTMLAnchorElement)?.href || ''
        return { title, price, image, location, url: href }
      }).filter(i => i.title && i.price > 0)
    })

    return items
  } finally {
    await (browser as { close: () => Promise<void> }).close()
  }
}

export async function fetchFacebookListings(): Promise<Listing[]> {
  const listings: Listing[] = []
  try {
    const items = await scrapeFacebook()
    for (const item of items) {
      const roi = await calculateROI(item.title, item.price)
      listings.push({
        id: `fb-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        source: 'facebook',
        title: item.title,
        buyPrice: item.price,
        estResalePrice: roi.estResalePrice,
        roi: roi.roi,
        riskScore: roi.riskScore,
        signalStrength: roi.signalStrength,
        classification: roi.classification,
        images: item.image ? [item.image] : [],
        listingUrl: item.url,
        location: item.location || 'Facebook Marketplace',
        condition: 'Used',
        category: 'Electronics',
        soldComps: roi.soldComps,
        scrapedAt: new Date().toISOString()
      })
    }
  } catch (e) {
    console.warn('[facebook] scrape failed (graceful fallback):', e)
  }
  return listings
}
