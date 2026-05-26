import * as admin from 'firebase-admin';
import * as dotenv from 'dotenv';

dotenv.config();

let db: admin.firestore.Firestore;
let auth: admin.auth.Auth;
let messaging: admin.messaging.Messaging;

try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: process.env.FIREBASE_DATABASE_URL,
    });
    console.log('🔥 Firebase Admin SDK initialized successfully via Environment Variable service account');
  } else {
    // Graceful fallback for local development without credentials
    admin.initializeApp({
      projectId: 'pulsesos-fallback-dev',
    });
    console.log('⚠️ Firebase initialized in DEVELOPMENT FALLBACK mode. Real auth calls will be mocked.');
  }

  db = admin.firestore();
  auth = admin.auth();
  messaging = admin.messaging();
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', error);
  process.exit(1);
}

export { db, auth, messaging };
export default admin;
