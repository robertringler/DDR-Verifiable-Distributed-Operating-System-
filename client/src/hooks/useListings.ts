import { useQuery } from '@tanstack/react-query'
import { fetchListings, fetchStats } from '../lib/api'
import { useFlipRadarStore } from '../store/flipradarStore'

export function useListings() {
  const filters = useFlipRadarStore(s => s.filters)
  return useQuery({
    queryKey: ['listings', filters],
    queryFn: () => fetchListings({
      source: filters.source,
      minROI: filters.minROI,
      maxRisk: filters.maxRisk,
      sort: filters.sort,
      category: filters.category || undefined
    }),
    refetchInterval: 60_000
  })
}

export function useStats() {
  return useQuery({
    queryKey: ['stats'],
    queryFn: fetchStats,
    refetchInterval: 60_000
  })
}
