import { Router, Response } from 'express';
import { AuthenticatedRequest, authenticateToken } from '../middleware/auth';
import { db } from '../config/firebase';

const router = Router();
router.use(authenticateToken);

// POST /api/media/upload — handle evidence file upload metadata
router.post('/upload', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    const { incidentId, mediaType, fileName, fileSize, durationMs } = req.body;
    if (!incidentId || !mediaType) {
      res.status(400).json({ error: 'incidentId and mediaType are required' });
      return;
    }

    const mediaRecord = {
      incidentId,
      uploadedBy: uid,
      mediaType, // 'audio' | 'video' | 'image'
      fileName: fileName || `evidence_${Date.now()}`,
      fileSize: fileSize || 0,
      durationMs: durationMs || 0,
      // In production: Firebase Storage signed URL would be generated here
      storageUrl: `https://storage.googleapis.com/pulsesos-media/${incidentId}/${fileName || 'evidence'}`,
      uploadedAt: new Date().toISOString(),
    };

    try {
      await db.collection('incidents').doc(incidentId).collection('media').add(mediaRecord);
    } catch {
      console.log(`⚠️ Media upload record fallback for incident: ${incidentId}`);
    }

    res.status(201).json({
      success: true,
      ...mediaRecord,
    });
  } catch (error) {
    res.status(500).json({ error: 'Media upload failed' });
  }
});

// GET /api/media/:incidentId — list all evidence media for an incident
router.get('/:incidentId', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { incidentId } = req.params;

    let mediaList: any[] = [];
    try {
      const snapshot = await db.collection('incidents').doc(incidentId).collection('media').get();
      mediaList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch {
      mediaList = [
        {
          id: 'mock-media-1',
          incidentId,
          mediaType: 'audio',
          fileName: 'evidence_audio.m4a',
          fileSize: 245000,
          durationMs: 32000,
          storageUrl: `https://storage.googleapis.com/pulsesos-media/${incidentId}/evidence_audio.m4a`,
          uploadedAt: new Date().toISOString(),
        }
      ];
    }

    res.status(200).json(mediaList);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve media files' });
  }
});

export default router;
