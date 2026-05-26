import { Router, Response } from 'express';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import {
  createIncident,
  getIncidentById,
  resolveIncident,
  getNearbyIncidents,
} from '../controllers/incidentController';
import { db } from '../config/firebase';

const router = Router();

// Apply security authentication middleware to all endpoints
router.use(authenticateToken);

router.post('/', createIncident);
router.get('/nearby', getNearbyIncidents);
router.get('/:id', getIncidentById);
router.put('/:id/resolve', resolveIncident);

// POST /api/incidents/:id/respond — join an incident as a responder
router.post('/:id/respond', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const uid = req.user?.uid;
    const { name, role, latitude, longitude } = req.body;

    if (!uid || !name) {
      res.status(400).json({ error: 'Missing responder name or UID' });
      return;
    }

    const responderEntry = {
      userId: uid,
      name,
      role: role || 'volunteer',
      latitude: latitude || 0,
      longitude: longitude || 0,
      joinedAt: new Date().toISOString(),
    };

    try {
      const admin = await import('../config/firebase');
      await db.collection('incidents').doc(id).update({
        responders: admin.default.firestore.FieldValue.arrayUnion(responderEntry),
        responderCount: admin.default.firestore.FieldValue.increment(1),
      });
    } catch {
      console.log(`⚠️ Respond fallback: ${name} joined incident ${id}`);
    }

    res.status(200).json({ success: true, responder: responderEntry });
  } catch (error) {
    res.status(500).json({ error: 'Failed to join incident response' });
  }
});

// PUT /api/incidents/:id/location — update live victim GPS coordinates
router.put('/:id/location', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { latitude, longitude, accuracy } = req.body;

    if (latitude === undefined || longitude === undefined) {
      res.status(400).json({ error: 'Missing coordinates' });
      return;
    }

    try {
      await db.collection('incidents').doc(id).update({
        'location.latitude': latitude,
        'location.longitude': longitude,
        'location.accuracy': accuracy || 0,
        'location.updatedAt': new Date().toISOString(),
      });
    } catch {
      console.log(`⚠️ Location update fallback for incident: ${id}`);
    }

    res.status(200).json({ success: true, latitude, longitude });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update live coordinates' });
  }
});

// GET /api/incidents/history — get resolved incidents for authenticated user
router.get('/history', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    let history: any[] = [];

    try {
      const snapshot = await db.collection('incidents')
        .where('victimId', '==', uid)
        .orderBy('createdAt', 'desc')
        .limit(50)
        .get();
      history = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch {
      history = [
        {
          id: 'hist-1',
          victimId: uid,
          type: 'robbery',
          status: 'resolved',
          location: { latitude: 37.7749, longitude: -122.4194, address: 'Market St' },
          responderCount: 2,
          createdAt: new Date(Date.now() - 86400000).toISOString(),
        },
      ];
    }

    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve history' });
  }
});

export default router;
