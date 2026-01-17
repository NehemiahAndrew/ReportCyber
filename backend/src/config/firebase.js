const admin = require('firebase-admin');
const config = require('./config');

let firebaseApp = null;
let firebaseDisabled = false;

const initializeFirebase = () => {
  // Skip if already disabled or initialized
  if (firebaseDisabled) {
    return null;
  }
  
  if (firebaseApp) {
    return firebaseApp;
  }

  // Check if Firebase is configured (not using placeholder values)
  const isConfigured = config.firebase.privateKey && 
    !config.firebase.privateKey.includes('DEV_KEY_PLACEHOLDER') &&
    !config.firebase.privateKey.includes('YOUR_KEY_HERE');

  if (!isConfigured) {
    console.log('Firebase: Skipping initialization (not configured - using local storage)');
    firebaseDisabled = true;
    return null;
  }

  try {
    const serviceAccount = {
      type: 'service_account',
      project_id: config.firebase.projectId,
      private_key_id: config.firebase.privateKeyId,
      private_key: config.firebase.privateKey,
      client_email: config.firebase.clientEmail,
      client_id: config.firebase.clientId,
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(config.firebase.clientEmail)}`,
    };

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: config.firebase.storageBucket,
    });

    console.log('Firebase initialized successfully');
    return firebaseApp;
  } catch (error) {
    console.warn('Firebase initialization skipped:', error.message);
    firebaseDisabled = true;
    return null;
  }
};

const getFirebaseStorage = () => {
  if (!firebaseApp) {
    initializeFirebase();
  }
  return admin.storage().bucket();
};

const getFirebaseAuth = () => {
  if (!firebaseApp) {
    initializeFirebase();
  }
  return admin.auth();
};

module.exports = {
  initializeFirebase,
  getFirebaseStorage,
  getFirebaseAuth,
  admin,
};
