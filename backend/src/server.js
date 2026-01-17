const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const passport = require('passport');

const config = require('./config/config');
const connectDB = require('./config/database');
const { initializeFirebase } = require('./config/firebase');
const configurePassport = require('./config/passport');
const errorHandler = require('./middleware/errorHandler');
const { apiLimiter } = require('./middleware/rateLimiter');
const logger = require('./utils/logger');
const AppError = require('./utils/AppError');

const {
  authRoutes,
  userRoutes,
  reportRoutes,
  verificationRoutes,
  adminRoutes,
  notificationRoutes,
} = require('./routes');

// Initialize Express app
const app = express();

// Trust proxy (for rate limiting behind reverse proxy)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: config.security.corsOrigin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Compression
app.use(compression());

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (config.env !== 'test') {
  app.use(morgan('combined', { stream: logger.stream }));
}

// Rate limiting
app.use('/api/', apiLimiter);

// Initialize Passport
configurePassport();
app.use(passport.initialize());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// API routes
const apiVersion = `/api/${config.apiVersion}`;

app.use(`${apiVersion}/auth`, authRoutes);
app.use(`${apiVersion}/users`, userRoutes);
app.use(`${apiVersion}/reports`, reportRoutes);
app.use(`${apiVersion}/admin`, adminRoutes);
app.use(`${apiVersion}/notifications`, notificationRoutes);
app.use(`${apiVersion}/verify`, verificationRoutes);

// API documentation endpoint
app.get(`${apiVersion}`, (req, res) => {
  res.json({
    success: true,
    message: 'ReportCyber API v1',
    version: config.apiVersion,
    endpoints: {
      auth: `${apiVersion}/auth`,
      users: `${apiVersion}/users`,
      reports: `${apiVersion}/reports`,
      admin: `${apiVersion}/admin`,
      notifications: `${apiVersion}/notifications`,
    },
    documentation: '/api-docs',
  });
});

// 404 handler
app.all('*', (req, res, next) => {
  next(new AppError(`Cannot find ${req.originalUrl} on this server`, 404));
});

// Global error handler
app.use(errorHandler);

// Start server
const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();
    
    // Initialize Firebase
    initializeFirebase();
    
    // Start listening
    const server = app.listen(config.port, () => {
      logger.info(`🚀 Server running in ${config.env} mode on port ${config.port}`);
      logger.info(`📡 API available at http://localhost:${config.port}/api/${config.apiVersion}`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM received. Shutting down gracefully...');
      server.close(() => {
        logger.info('Process terminated');
        process.exit(0);
      });
    });

    process.on('unhandledRejection', (err) => {
      logger.error('Unhandled Rejection:', err);
      server.close(() => {
        process.exit(1);
      });
    });

  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Run if this file is executed directly
if (require.main === module) {
  startServer();
}

module.exports = app;
