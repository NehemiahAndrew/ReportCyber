const jwt = require('jsonwebtoken');
const { promisify } = require('util');
const config = require('../config/config');
const User = require('../models/User');
const AppError = require('../utils/AppError');

/**
 * Authenticate user using JWT
 */
const authenticate = async (req, res, next) => {
  try {
    // 1) Get token from header
    let token;
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return next(new AppError('You are not logged in. Please log in to get access.', 401));
    }

    // 2) Verify token
    const decoded = await promisify(jwt.verify)(token, config.jwt.accessSecret);

    // 3) Check if user still exists
    const user = await User.findById(decoded.id);
    if (!user) {
      return next(new AppError('The user belonging to this token no longer exists.', 401));
    }

    // 4) Check if user is active and not blocked
    if (!user.isActive) {
      return next(new AppError('Your account has been deactivated.', 401));
    }

    if (user.isBlocked) {
      return next(new AppError('Your account has been blocked. Please contact support.', 403));
    }

    // 5) Check if user changed password after the token was issued
    if (user.changedPasswordAfter(decoded.iat)) {
      return next(new AppError('Password recently changed. Please log in again.', 401));
    }

    // Grant access
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return next(new AppError('Invalid token. Please log in again.', 401));
    }
    if (error.name === 'TokenExpiredError') {
      return next(new AppError('Your session has expired. Please log in again.', 401));
    }
    return next(error);
  }
};

/**
 * Optional authentication - doesn't fail if no token
 */
const optionalAuth = async (req, res, next) => {
  try {
    let token;
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return next();
    }

    const decoded = await promisify(jwt.verify)(token, config.jwt.accessSecret);
    const user = await User.findById(decoded.id);
    
    if (user && user.isActive && !user.isBlocked) {
      req.user = user;
    }
    
    next();
  } catch (error) {
    // Just continue without user if token is invalid
    next();
  }
};

/**
 * Restrict to specific roles
 */
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(
        new AppError('You do not have permission to perform this action.', 403)
      );
    }
    next();
  };
};

/**
 * Check if user owns the resource or is admin/moderator
 */
const checkOwnership = (model) => {
  return async (req, res, next) => {
    try {
      const resource = await model.findById(req.params.id);
      
      if (!resource) {
        return next(new AppError('Resource not found.', 404));
      }

      const isOwner = resource.reporter?.toString() === req.user.id;
      const isPrivileged = ['admin', 'moderator', 'analyst'].includes(req.user.role);

      if (!isOwner && !isPrivileged) {
        return next(new AppError('You do not have permission to access this resource.', 403));
      }

      req.resource = resource;
      next();
    } catch (error) {
      next(error);
    }
  };
};

module.exports = {
  authenticate,
  optionalAuth,
  restrictTo,
  checkOwnership,
};
