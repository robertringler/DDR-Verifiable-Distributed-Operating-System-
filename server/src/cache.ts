import NodeCache from 'node-cache'

const cache = new NodeCache({ stdTTL: 300, checkperiod: 60 })

export function getCache<T>(key: string): T | undefined {
  return cache.get<T>(key)
}

export function setCache<T>(key: string, value: T): void {
  cache.set(key, value)
}

export function deleteCache(key: string): void {
  cache.del(key)
}
