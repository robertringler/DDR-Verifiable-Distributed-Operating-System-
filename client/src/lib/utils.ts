import type { SignalClass } from '../types'

export function formatCurrency(n: number): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(n)
}

export function formatROI(n: number): string {
  return `${n >= 0 ? '+' : ''}${Math.round(n)}%`
}

export function sigColor(cls: SignalClass): string {
  const map: Record<SignalClass, string> = {
    HOT_OPPORTUNITY: '#10B981',
    STRONG_SIGNAL: '#C8A24A',
    WATCH: '#3B82F6',
    LOW_OPPORTUNITY: '#94A3B8'
  }
  return map[cls]
}

export function classifyLabel(cls: SignalClass): string {
  const map: Record<SignalClass, string> = {
    HOT_OPPORTUNITY: 'HOT',
    STRONG_SIGNAL: 'STRONG',
    WATCH: 'WATCH',
    LOW_OPPORTUNITY: 'LOW'
  }
  return map[cls]
}

export function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m}m ago`
  return `${Math.floor(m / 60)}h ago`
}
