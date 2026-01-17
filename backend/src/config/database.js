const mongoose = require('mongoose');
const config = require('./config');
const logger = require('../utils/logger');

const connectDB = async () => {
  try {
    const mongoUri = config.mongoose.url;
    
    // Remove deprecated options
    const options = {};
    
    await mongoose.connect(mongoUri, options);
    logger.info(`MongoDB Connected: ${mongoose.connection.host}`);
    
    mongoose.connection.on('error', (err) => {
      logger.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected. Attempting to reconnect...');
    });
    
    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });
    
    return mongoose.connection;
  } catch (error) {
    logger.error('MongoDB connection failed:', error.message);
    logger.error('Please ensure MongoDB is running or use MongoDB Atlas.');
    logger.error('For MongoDB Atlas: Update MONGODB_URI in .env with your connection string.');
    process.exit(1);
  }
};

module.exports = connectDB;
