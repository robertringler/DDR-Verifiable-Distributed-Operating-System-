import { useState } from 'react'
import Header from './components/layout/Header'
import Dashboard from './components/pages/Dashboard'
import Opportunities from './components/pages/Opportunities'
import Analytics from './components/pages/Analytics'
import Watchlist from './components/pages/Watchlist'
import Portfolio from './components/pages/Portfolio'

export type Page = 'dashboard' | 'opportunities' | 'analytics' | 'watchlist' | 'portfolio'

export default function App() {
  const [page, setPage] = useState<Page>('dashboard')

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Header page={page} onNav={setPage} />
      <main style={{ flex: 1 }}>
        {page === 'dashboard' && <Dashboard />}
        {page === 'opportunities' && <Opportunities />}
        {page === 'analytics' && <Analytics />}
        {page === 'watchlist' && <Watchlist />}
        {page === 'portfolio' && <Portfolio />}
      </main>
    </div>
  )
}
