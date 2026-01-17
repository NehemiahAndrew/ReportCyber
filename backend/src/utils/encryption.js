const CryptoJS = require('crypto-js');
const crypto = require('crypto');
const config = require('../config/config');

/**
 * Encrypt data using AES-256
 * @param {string} data - Data to encrypt
 * @returns {string} - Encrypted data
 */
const encrypt = (data) => {
  if (!data) return null;
  const encrypted = CryptoJS.AES.encrypt(data, config.security.encryptionKey).toString();
  return encrypted;
};

/**
 * Decrypt data using AES-256
 * @param {string} encryptedData - Encrypted data
 * @returns {string} - Decrypted data
 */
const decrypt = (encryptedData) => {
  if (!encryptedData) return null;
  const bytes = CryptoJS.AES.decrypt(encryptedData, config.security.encryptionKey);
  const decrypted = bytes.toString(CryptoJS.enc.Utf8);
  return decrypted;
};

/**
 * Generate SHA-256 hash
 * @param {string} data - Data to hash
 * @returns {string} - Hashed data
 */
const generateHash = (data) => {
  return CryptoJS.SHA256(data).toString();
};

/**
 * Generate secure random token
 * @param {number} length - Token length in bytes
 * @returns {string} - Random token
 */
const generateSecureToken = (length = 32) => {
  return crypto.randomBytes(length).toString('hex');
};

/**
 * Encrypt file buffer using AES-256
 * @param {Buffer} buffer - File buffer
 * @returns {Object} - Encrypted buffer and IV
 */
const encryptFile = (buffer) => {
  const iv = crypto.randomBytes(16);
  const key = crypto.scryptSync(config.security.encryptionKey, 'salt', 32);
  const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
  const encrypted = Buffer.concat([cipher.update(buffer), cipher.final()]);
  return {
    encryptedBuffer: encrypted,
    iv: iv.toString('hex'),
  };
};

/**
 * Decrypt file buffer using AES-256
 * @param {Buffer} encryptedBuffer - Encrypted file buffer
 * @param {string} ivHex - IV in hex format
 * @returns {Buffer} - Decrypted buffer
 */
const decryptFile = (encryptedBuffer, ivHex) => {
  const iv = Buffer.from(ivHex, 'hex');
  const key = crypto.scryptSync(config.security.encryptionKey, 'salt', 32);
  const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
  const decrypted = Buffer.concat([decipher.update(encryptedBuffer), decipher.final()]);
  return decrypted;
};

/**
 * Generate file hash for integrity verification
 * @param {Buffer} buffer - File buffer
 * @returns {string} - SHA-256 hash
 */
const generateFileHash = (buffer) => {
  return crypto.createHash('sha256').update(buffer).digest('hex');
};

module.exports = {
  encrypt,
  decrypt,
  generateHash,
  generateSecureToken,
  encryptFile,
  decryptFile,
  generateFileHash,
};
