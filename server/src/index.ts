import express from 'express'
import cors from 'cors'
import path from 'path'
import dotenv from 'dotenv'
import listingsRouter from './routes/listings'
import statsRouter from './routes/stats'
import { startScheduler } from './scheduler'

dotenv.config()

const app = express()
const PORT = parseInt(process.env.PORT || '3001', 10)

app.use(cors())
app.use(express.json())

app.use('/api/listings', listingsRouter)
app.use('/api/stats', statsRouter)

const publicPath = path.join(__dirname, 'public')
app.use(express.static(publicPath))
app.get('*', (_req, res) => {
  res.sendFile(path.join(publicPath, 'index.html'))
})

app.listen(PORT, () => {
  console.log(`FlipRadar server running on port ${PORT}`)
  startScheduler()
})

export default app
