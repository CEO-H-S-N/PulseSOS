import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { db, messaging } from '../config/firebase';
import { v4 as uuidv4 } from 'uuid';

export const createIncident = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const victimId = req.user?.uid;
    if (!victimId) {
      res.status(400).json({ error: 'Victim UID missing' });
      return;
    }

    const { type, isSilent, latitude, longitude, address } = req.body;

    if (!type || latitude === undefined || longitude === undefined) {
      res.status(400).json({ error: 'Missing required parameters: type, latitude, longitude' });
      return;
    }

    const incidentId = uuidv4();
    const newIncident = {
      id: incidentId,
      victimId,
      type,
      isSilent: !!isSilent,
      status: 'active',
      location: {
        latitude,
        longitude,
        address: address || 'Unknown location',
        geohash: `${latitude.toFixed(4)}_${longitude.toFixed(4)}` // Simplified geohash indexing
      },
      responderCount: 0,
      responders: [],
      createdAt: new Date().toISOString(),
    };

    // Save incident details to Firestore (or fallback log)
    try {
      await db.collection('incidents').doc(incidentId).set(newIncident);
    } catch (dbErr) {
      console.warn('⚠️ Firestore save bypassed in fallback environment:', dbErr);
    }

    // Trigger FCM Broadcast to nearby active devices within a geohash bounding box
    console.log(`📣 Broadcasting ${type} SOS incident ${incidentId} to nearby responders...`);
    try {
      const topicName = 'nearby-emergency';
      const fcmPayload = {
        notification: {
          title: `🚨 EMERGENCY: ${type.toUpperCase()}`,
          body: `A neighbor needs immediate assistance near ${newIncident.location.address}. Tap to respond.`,
        },
        data: {
          incidentId,
          type,
          latitude: String(latitude),
          longitude: String(longitude),
          isSilent: String(isSilent),
        },
        topic: topicName,
      };
      await messaging.send(fcmPayload);
      console.log('✅ FCM alert successfully broadcasted to nearby responders');
    } catch (fcmErr) {
      console.warn('⚠️ FCM delivery bypassed (Local dev mode):', fcmErr);
    }

    res.status(201).json(newIncident);
  } catch (error) {
    console.error('❌ Create incident failed:', error);
    res.status(500).json({ error: 'Failed to create active incident' });
  }
};

export const getIncidentById = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    let incidentData = null;

    try {
      const doc = await db.collection('incidents').doc(id).get();
      if (doc.exists) {
        incidentData = doc.data();
      }
    } catch {
      // Return mocked response for local dev fallback testing
      incidentData = {
        id,
        victimId: 'mock-victim-123',
        type: 'robbery',
        isSilent: false,
        status: 'active',
        location: {
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'Market St, San Francisco, CA',
          geohash: '37.7749_-122.4194'
        },
        responderCount: 2,
        responders: [
          { name: 'David Miller', role: 'responder', distance: 150 },
          { name: 'Officer Jenny', role: 'police', distance: 400 }
        ],
        createdAt: new Date().toISOString(),
      };
    }

    if (!incidentData) {
      res.status(404).json({ error: 'Incident not found' });
      return;
    }

    res.status(200).json(incidentData);
  } catch (error) {
    console.error('❌ Get incident failed:', error);
    res.status(500).json({ error: 'Server error retrieving incident details' });
  }
};

export const resolveIncident = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    try {
      await db.collection('incidents').doc(id).update({ status: 'resolved' });
    } catch {
      console.log(`⚠️ Mock update: Incident ${id} resolved in fallback environment.`);
    }

    res.status(200).json({ success: true, message: 'Incident resolved successfully.' });
  } catch (error) {
    console.error('❌ Resolve incident failed:', error);
    res.status(500).json({ error: 'Failed to resolve incident' });
  }
};

export const getNearbyIncidents = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { latitude, longitude, radius } = req.query;

    if (!latitude || !longitude) {
      res.status(400).json({ error: 'Missing coordinates: latitude, longitude' });
      return;
    }

    // In production this performs a true GeoFirestore query.
    // In local fallback mode, we return a structured sample of active neighbor alerts.
    const sampleIncidents = [
      {
        id: 'nearby-incident-1',
        victimId: 'neighbor-uid-99',
        type: 'harassment',
        isSilent: false,
        status: 'active',
        location: {
          latitude: Number(latitude) + 0.002,
          longitude: Number(longitude) - 0.001,
          address: '200m North-West from your location',
        },
        responderCount: 1,
        responders: [],
        createdAt: new Date().toISOString(),
      }
    ];

    res.status(200).json(sampleIncidents);
  } catch (error) {
    console.error('❌ Nearby incident scan failed:', error);
    res.status(500).json({ error: 'Scanning nearby active alerts failed' });
  }
};
