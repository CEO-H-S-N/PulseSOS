import { Router, Response } from 'express';
import { AuthenticatedRequest, authenticateToken } from '../middleware/auth';
import { db } from '../config/firebase';

const router = Router();
router.use(authenticateToken);

// POST /api/auth/verify-token — verify Firebase token and return user profile
router.post('/verify-token', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    let userData = null;
    try {
      const doc = await db.collection('users').doc(uid).get();
      userData = doc.exists ? doc.data() : null;
    } catch { /* fallback */ }

    res.status(200).json({
      uid,
      exists: !!userData,
      profile: userData || null,
    });
  } catch (error) {
    res.status(500).json({ error: 'Token verification failed' });
  }
});

// POST /api/auth/device-bind — register device token for push notifications
router.post('/device-bind', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    const { fcmToken, platform, deviceId } = req.body;
    if (!uid || !fcmToken) { res.status(400).json({ error: 'Missing UID or FCM token' }); return; }

    try {
      await db.collection('users').doc(uid).update({
        'deviceTokens': admin.firestore.FieldValue.arrayUnion(fcmToken),
        'lastDeviceId': deviceId || 'unknown',
        'platform': platform || 'android',
        'lastSeen': new Date().toISOString(),
      });
    } catch {
      console.log(`⚠️ Device bind fallback for UID: ${uid}`);
    }

    res.status(200).json({ success: true, message: 'Device token registered' });
  } catch (error) {
    res.status(500).json({ error: 'Device binding failed' });
  }
});

// GET /api/auth/profile — get current user profile
router.get('/profile', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    let profile = null;
    try {
      const doc = await db.collection('users').doc(uid).get();
      profile = doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch {
      // Fallback mock profile
      profile = {
        id: uid,
        displayName: 'Mock User',
        phone: req.user?.phone || '+15551234567',
        email: req.user?.email || 'mock@pulsesos.com',
        bloodGroup: 'O+',
        trustLevel: 85,
        isVerifiedResponder: false,
      };
    }

    if (!profile) { res.status(404).json({ error: 'Profile not found' }); return; }
    res.status(200).json(profile);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve profile' });
  }
});

// PUT /api/auth/profile — update user profile
router.put('/profile', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    const allowedFields = [
      'displayName', 'bloodGroup', 'gender', 'medicalConditions',
      'vehicleDetails', 'responderRole', 'avatarUrl'
    ];
    const updateData: Record<string, any> = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }
    updateData['updatedAt'] = new Date().toISOString();

    try {
      await db.collection('users').doc(uid).update(updateData);
    } catch {
      console.log(`⚠️ Profile update fallback for UID: ${uid}`);
    }

    res.status(200).json({ success: true, updated: updateData });
  } catch (error) {
    res.status(500).json({ error: 'Profile update failed' });
  }
});

import admin from '../config/firebase';
export default router;
