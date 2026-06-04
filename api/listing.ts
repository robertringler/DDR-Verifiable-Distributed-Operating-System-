import type { VercelRequest, VercelResponse } from '@vercel/node'
import { fetchEbayListings } from '../server/src/services/ebay'
import { fetchGovDealsListings } from '../server/src/services/govdeals'
import { fetchFacebookListings } from '../server/src/services/facebook'
import type { Listing } from '../server/src/types'

const QUERIES = [
  'cisco switch', 'fluke multimeter', 'tektronix oscilloscope',
  'rolex watch', 'jordan sneakers', 'milwaukee tools',
  'ipad', 'macbook', 'samsung galaxy'
]

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const id = req.query.id as string
  if (!id) return res.status(400).json({ error: 'Missing id' })

  const settled = await Promise.allSettled([
    fetchEbayListings(QUERIES), fetchGovDealsListings(), fetchFacebookListings()
  ])
  const all: Listing[] = []
  for (const r of settled) if (r.status === 'fulfilled') all.push(...r.value)

  const found = all.find(l => l.id === id)
  if (!found) return res.status(404).json({ error: 'Not found' })
  res.status(200).json(found)
}
