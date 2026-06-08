import type { Listing } from '../types'

/**
 * Facebook Marketplace adapter — STUB.
 *
 * Meta does not expose a public Marketplace API, and automated browsing of
 * Facebook violates their Terms of Service. This adapter is intentionally left
 * as a documented stub that returns an empty array so the rest of the pipeline
 * (multi-source aggregation, filters, stats) treats Facebook as a zero-result
 * source rather than an error.
 *
 * To enable a real Facebook source in the future, implement one of:
 *   1. An official Meta Commerce / Marketplace API (if/when Meta opens access).
 *   2. A compliant third-party data provider that licenses FB Marketplace data.
 *
 * Whatever the source, map each item into the shared `Listing` shape
 * (run buyPrice + title through `calculateROI` for estResalePrice/roi/risk)
 * and return the array here. No other code needs to change.
 */
export async function fetchFacebookListings(): Promise<Listing[]> {
  return []
}
