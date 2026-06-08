# FlipRadar

> Live deal-intelligence platform — real listings from eBay and GovDeals with instant ROI calculations from real sold comps. Zero mock data.

---

## Features

- **Live eBay data** — active listings + sold comps via the eBay Finding API (real product images, real prices)
- **GovDeals auctions** — government surplus via the Apify GovDeals scraper
- **ROI Engine** — median of last 10 eBay sold comps → profit %, risk score (0–100), signal classification (HOT / STRONG / WATCH / LOW)
- **Real product images** pulled straight from listing CDNs
- **Analytics** — ROI-vs-Risk scatter, category bar chart, marketplace pie, signal distribution (Recharts, all from live data)
- **Watchlist & Portfolio** — save deals, track purchases and P&L (persisted to localStorage)

> **Facebook Marketplace** is included as a documented adapter stub. Meta exposes no public Marketplace API and automated browsing violates their ToS, so the adapter returns zero results until a compliant data source is wired in (see `server/src/services/facebook.ts`). The UI treats it as a zero-result source, not an error.

---

## Architecture

```
flipradar/
├─ api/                 ← Vercel serverless functions (listings, listing, stats)
├─ server/src/services  ← shared data services (ebay, govdeals, facebook, resaleCalc)
├─ client/              ← React 18 + Vite + Zustand + TanStack Query frontend
└─ vercel.json          ← build + routing config
```

The same `server/src/services/*` modules power both the Vercel serverless
functions (production) and the standalone Express server (`server/src/index.ts`,
useful for local all-in-one dev or a Railway/VPS deploy).

---

## Quick Start (local)

```bash
cp .env.example .env       # then fill in EBAY_APP_ID + APIFY_API_KEY
npm install
npm install --prefix client
npm install --prefix server
npm run dev                # Express API :3001 + Vite client :5173
```

Client: http://localhost:5173 · API: http://localhost:3001/api/listings

---

## eBay API Key Setup (free — 5 steps)

The eBay Finding API needs only an **App ID (Client ID)** — no OAuth, no approval wait.

1. Go to https://developer.ebay.com/signin and sign in (or create a free account)
2. Open **My Account → Application Keys**
3. Click **Create a keyset** under **Production**
4. Copy the **App ID (Client ID)** value
5. Paste it into `.env` (local) and into Vercel project env vars (production) as `EBAY_APP_ID`

---

## Apify API Key Setup (GovDeals — free tier)

1. Create a free account at https://apify.com
2. Go to **Settings → Integrations → API token**
3. Copy the token → set it as `APIFY_API_KEY` (local `.env` + Vercel env vars)

---

## Deploy to Vercel (recommended)

1. Push this repo to GitHub
2. Go to https://vercel.com → **Add New → Project** → import this repo
3. Vercel auto-detects `vercel.json`:
   - Frontend builds from `client/` → served as static
   - `api/*.ts` deploy as serverless functions at `/api/*`
4. Add Environment Variables in the Vercel dashboard:
   - `EBAY_APP_ID`
   - `APIFY_API_KEY`
5. Deploy — your live HTTPS URL is ready in ~1 minute

> Serverless functions are stateless; responses are edge-cached for 5 minutes
> via `Cache-Control: s-maxage=300` so repeat visitors get fast, fresh data
> without re-hitting the marketplaces on every request.

### Alternative: Railway / VPS (persistent server)

The repo also ships a standalone Express server with a `node-cron` 5-minute
refresh scheduler. To run it: `npm run build --prefix server && npm start`.
Set the same env vars and point your host at `server/dist/index.js`.

---

## API Endpoints

```
GET /api/listings?source=all|ebay|govdeals|facebook&minROI=0&maxRisk=100&sort=roi|price|risk|newest&category=Electronics
GET /api/listings/:id        (rewritten to /api/listing?id=:id on Vercel)
GET /api/stats
```

## ROI Engine

For each candidate listing, FlipRadar fetches the last ~10 **sold** eBay comps
for the item's title, takes the **median** sale price as estimated resale value,
and computes:

- `roi = (medianResale - buyPrice) / buyPrice * 100`
- `riskScore` from the price variance of sold comps (0 = tight/safe, 100 = volatile)
- `signalStrength` blending ROI and inverse-variance → HOT / STRONG / WATCH / LOW

## Tech Stack

| Layer | Tech |
|-------|------|
| Serverless API | Vercel Functions (`@vercel/node`), TypeScript |
| Data services | Axios, Cheerio, Apify REST |
| Caching | node-cache + edge `s-maxage` |
| Client | React 18, TypeScript, Vite |
| State | Zustand (persisted) + TanStack Query (60s polling) |
| Charts | Recharts |
