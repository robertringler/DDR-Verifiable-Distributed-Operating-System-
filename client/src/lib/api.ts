import type { Listing, Stats } from '../types'

const BASE = '/api'

export async function fetchListings(params: {
  source?: string
  minROI?: number
  maxRisk?: number
  sort?: string
  category?: string
} = {}): Promise<Listing[]> {
  const qs = new URLSearchParams()
  if (params.source) qs.set('source', params.source)
  if (params.minROI != null) qs.set('minROI', String(params.minROI))
  if (params.maxRisk != null) qs.set('maxRisk', String(params.maxRisk))
  if (params.sort) qs.set('sort', params.sort)
  if (params.category) qs.set('category', params.category)
  const res = await fetch(`${BASE}/listings?${qs}`)
  if (!res.ok) throw new Error('Failed to fetch listings')
  return res.json()
}

export async function fetchListing(id: string): Promise<Listing> {
  const res = await fetch(`${BASE}/listings/${id}`)
  if (!res.ok) throw new Error('Listing not found')
  return res.json()
}

export async function fetchStats(): Promise<Stats> {
  const res = await fetch(`${BASE}/stats`)
  if (!res.ok) throw new Error('Failed to fetch stats')
  return res.json()
}
