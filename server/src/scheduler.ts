import cron from 'node-cron'
import { fetchEbayListings } from './services/ebay'
import { fetchGovDealsListings } from './services/govdeals'
import { fetchFacebookListings } from './services/facebook'
import { setCache } from './cache'

const QUERIES = [
  'cisco switch', 'fluke multimeter', 'tektronix oscilloscope',
  'rolex watch', 'jordan sneakers', 'milwaukee tools',
  'ipad', 'macbook', 'samsung galaxy', 'generators', 'golf clubs'
]

async function refreshAll(): Promise<void> {
  console.log('[scheduler] refreshing all sources...')
  try {
    const ebay = await fetchEbayListings(QUERIES)
    setCache('listings:ebay', ebay)
  } catch (e) {
    console.error('[scheduler] eBay error:', e)
  }
  try {
    const gov = await fetchGovDealsListings()
    setCache('listings:govdeals', gov)
  } catch (e) {
    console.error('[scheduler] GovDeals error:', e)
  }
  try {
    const fb = await fetchFacebookListings()
    setCache('listings:facebook', fb)
  } catch (e) {
    console.error('[scheduler] Facebook error:', e)
  }
  setCache('stats:lastRefresh', new Date().toISOString())
  console.log('[scheduler] refresh complete')
}

export function startScheduler(): void {
  refreshAll()
  cron.schedule('*/5 * * * *', refreshAll)
}
