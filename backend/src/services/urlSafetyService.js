const axios = require('axios');
const config = require('../config/config');
const logger = require('../utils/logger');

/**
 * Check URL safety using Google Safe Browsing API
 * @param {string} url - URL to check
 * @returns {Promise<Object>} - Safety check result
 */
const checkUrlSafety = async (url) => {
  try {
    // If no API key configured, return unknown
    if (!config.googleSafeBrowsing.apiKey) {
      logger.warn('Google Safe Browsing API key not configured');
      return {
        isSafe: null,
        threats: [],
        message: 'Safety check not available',
      };
    }

    const apiUrl = `https://safebrowsing.googleapis.com/v4/threatMatches:find?key=${config.googleSafeBrowsing.apiKey}`;

    const requestBody = {
      client: {
        clientId: 'reportcyber',
        clientVersion: '1.0.0',
      },
      threatInfo: {
        threatTypes: [
          'MALWARE',
          'SOCIAL_ENGINEERING',
          'UNWANTED_SOFTWARE',
          'POTENTIALLY_HARMFUL_APPLICATION',
        ],
        platformTypes: ['ANY_PLATFORM'],
        threatEntryTypes: ['URL'],
        threatEntries: [{ url }],
      },
    };

    const response = await axios.post(apiUrl, requestBody, {
      timeout: 5000,
    });

    // If matches found, URL is unsafe
    if (response.data.matches && response.data.matches.length > 0) {
      const threats = response.data.matches.map((match) => match.threatType);
      return {
        isSafe: false,
        threats,
        message: `URL flagged for: ${threats.join(', ')}`,
      };
    }

    return {
      isSafe: true,
      threats: [],
      message: 'No threats detected',
    };
  } catch (error) {
    logger.error('URL safety check error:', error.message);
    return {
      isSafe: null,
      threats: [],
      message: 'Safety check failed',
      error: error.message,
    };
  }
};

/**
 * Validate URL format
 * @param {string} url - URL to validate
 * @returns {boolean} - Is valid URL
 */
const isValidUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

/**
 * Extract domain from URL
 * @param {string} url - URL to extract domain from
 * @returns {string} - Domain
 */
const extractDomain = (url) => {
  try {
    const urlObj = new URL(url);
    return urlObj.hostname;
  } catch {
    return null;
  }
};

module.exports = {
  checkUrlSafety,
  isValidUrl,
  extractDomain,
};
