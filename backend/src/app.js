const express = require('express');
const cors = require('cors');
const errorHandler = require('./middlewares/errorHandler');
const authRoutes = require('./routes/authRoutes');
const ghRoutes = require('./routes/ghRoutes');

const app = express();

// Middleware dasar
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root health check
app.get('/', (req, res) => {
  res.status(200).json({
    app: 'Smart Tani / TaniGreen REST API Server',
    status: 'Online',
    version: '1.0.0',
    documentation: '/docs/API.md',
    timestamp: new Date().toISOString(),
  });
});

// Routing API
app.use('/api/auth', authRoutes);
app.use('/api', ghRoutes);

// Error Handler terpusat
app.use(errorHandler);

module.exports = app;
