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
// Allow all origins during development (Flutter Web runs on localhost:*).
// For production, replace '*' with your actual domain(s):
//   origin: ['https://your-app.com', 'http://10.0.1.45:8080']
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false,           // must be false when origin is '*'
};
app.use(cors(corsOptions));
// Ensure pre-flight OPTIONS requests are answered for all routes.
// '/{*any}' is the Express v5 / path-to-regexp v8 compatible wildcard.
app.options('/{*any}', cors(corsOptions));

app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
    next();
});

// Load Config from .env
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'gram_setu_secret_key_123!';
// 2. All API Routes (Centralized in routes/index.js)
app.use('/api', apiRoutes);

// Hello World Route for testing
app.get('/', (req, res) => res.send('Gram Setu Backend is Running!'));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});