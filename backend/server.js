require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const User = require('./models/User');
const apiRoutes = require('./routes/index');

const app = express();

// 1. Connect to MongoDB
connectDB();

// ── CORS ─────────────────────────────────────────────────────────────────────
// Use standard CORS middleware (handles all routes and OPTIONS automatically)
app.use(cors());

app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
    next();
});

// Load Config from .env
const os = require('os');
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'gram_setu_secret_key_123!';

// 2. All API Routes (Centralized in routes/index.js)
app.use('/api', apiRoutes);

// Hello World Route for testing
app.get('/', (req, res) => res.send('Gram Setu Backend is Running!'));

// Function to get local network IP
const getLocalIp = () => {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const entry of interfaces[name]) {
      if (entry.family === 'IPv4' && !entry.internal) {
        return entry.address;
      }
    }
  }
  return 'localhost';
};

app.listen(PORT, '0.0.0.0', () => {
  const localIp = getLocalIp();
  console.log(`\n🚀 Backend is LIVE!`);
  console.log(`🏠 Local:   http://localhost:${PORT}`);
  console.log(`🌐 Network: http://${localIp}:${PORT}`);
  console.log(`\n(Point your AppConstants.baseUrl to the Network URL if using a physical device)\n`);
});