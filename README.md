# FlipRadar

> Live deal-intelligence platform — real listings from eBay, GovDeals & Facebook Marketplace with instant ROI calculations.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

---

## Features

- **Live eBay data** — active listings + sold comps for real ROI calculations
- **GovDeals auctions** — government surplus electronics via Apify scraper
- **Facebook Marketplace** — scraped with stealth Puppeteer (graceful fallback)
- **ROI Engine** — median sold comps → profit %, risk score, signal classification
- **Real product images** from listing CDNs
- **Analytics** — scatter, bar, pie charts (Recharts)
- **Watchlist & Portfolio** — track deals, P&L

---

## Quick Start

```bash
cp .env.example .env
# Fill in your keys (see below)
npm install
npm run dev
```

Client: http://localhost:5173  
API: http://localhost:3001/api/listings

---

## eBay API Key Setup (free — 5 steps)

1. Go to https://developer.ebay.com/signin
2. Sign in with your eBay account (or create one free)
3. Click **"Get Started"** → **"Create Application"**
4. Enter app name `FlipRadar`, select **Production**
5. Copy your **App ID (Client ID)** → paste into `.env` as `EBAY_APP_ID`

> The Finding API only requires the App ID — no OAuth, no approval process.

---

## Apify API Key (GovDeals — free tier: 100 items/run)

1. Go to https://apify.com and create a free account
2. Dashboard → **Settings → Integrations → API token**
3. Copy token → paste into `.env` as `APIFY_API_KEY`

---

## Deploy to Railway

1. Push this repo to GitHub
2. Go to https://railway.app → New Project → Deploy from GitHub
3. Select this repo
4. Add environment variables in Railway dashboard:
   - `EBAY_APP_ID`
   - `APIFY_API_KEY`
   - `NODE_ENV=production`
5. Deploy — Railway auto-detects `railway.toml`

---

## API Endpoints

```
GET /api/listings?source=all&minROI=0&maxRisk=100&sort=roi
GET /api/listings/:id
GET /api/stats
```

## Tech Stack

| Layer | Tech |
|-------|------|
| Server | Node.js, Express, TypeScript |
| Scraping | Axios, Cheerio, Puppeteer Extra |
| Caching | node-cache (5 min TTL) |
| Client | React 18, TypeScript, Vite |
| State | Zustand + TanStack Query |
| Charts | Recharts |
| Deploy | Railway (nixpacks) |
