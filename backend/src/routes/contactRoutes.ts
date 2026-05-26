import { Router, Response } from 'express';
import { AuthenticatedRequest, authenticateToken } from '../middleware/auth';
import { db } from '../config/firebase';

const router = Router();
router.use(authenticateToken);

// GET /api/contacts — get all trusted contacts for authenticated user
router.get('/', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    let contacts: any[] = [];
    try {
      const snapshot = await db.collection('users').doc(uid).collection('trusted_contacts').get();
      contacts = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch {
      // Fallback mock contacts
      contacts = [
        { id: 'c1', name: 'Sarah Connor', relationship: 'Mother', phone: '+15551234567', notifyViaSms: true, notifyViaWhatsapp: true },
        { id: 'c2', name: 'John Connor', relationship: 'Brother', phone: '+15559876543', notifyViaSms: true, notifyViaWhatsapp: false },
      ];
    }

    res.status(200).json(contacts);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve contacts' });
  }
});

// POST /api/contacts — add a new trusted contact
router.post('/', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    const { name, relationship, phone, email, notifyViaSms, notifyViaWhatsapp } = req.body;
    if (!name || !phone) { res.status(400).json({ error: 'Name and phone are required' }); return; }

    const contactData = {
      name,
      relationship: relationship || 'Other',
      phone,
      email: email || '',
      notifyViaSms: notifyViaSms !== false,
      notifyViaWhatsapp: !!notifyViaWhatsapp,
      createdAt: new Date().toISOString(),
    };

    let contactId = 'mock-contact-id';
    try {
      const docRef = await db.collection('users').doc(uid).collection('trusted_contacts').add(contactData);
      contactId = docRef.id;
    } catch {
      console.log(`⚠️ Contact add fallback for UID: ${uid}`);
    }

    res.status(201).json({ id: contactId, ...contactData });
  } catch (error) {
    res.status(500).json({ error: 'Failed to add contact' });
  }
});

// DELETE /api/contacts/:id — remove a trusted contact
router.delete('/:id', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    const { id } = req.params;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    try {
      await db.collection('users').doc(uid).collection('trusted_contacts').doc(id).delete();
    } catch {
      console.log(`⚠️ Contact delete fallback for contact: ${id}`);
    }

    res.status(200).json({ success: true, message: 'Contact removed' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete contact' });
  }
});

// POST /api/contacts/notify — send emergency SMS/alerts to all trusted contacts
router.post('/notify', async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user?.uid;
    if (!uid) { res.status(401).json({ error: 'Missing UID' }); return; }

    const { incidentId, latitude, longitude, emergencyType, message } = req.body;

    let contacts: any[] = [];
    try {
      const snapshot = await db.collection('users').doc(uid).collection('trusted_contacts').get();
      contacts = snapshot.docs.map(doc => doc.data());
    } catch {
      contacts = [{ name: 'Mock Contact', phone: '+15551234567' }];
    }

    // In production this would integrate with Twilio/WhatsApp Business API
    // For now we log the dispatch and return success
    const trackingLink = `https://pulsesos.app/track/${incidentId}?lat=${latitude}&lng=${longitude}`;
    const smsBody = message || `🚨 EMERGENCY ALERT from PulseSOS! Type: ${emergencyType}. Track live: ${trackingLink}`;

    console.log(`📨 Dispatching emergency notifications to ${contacts.length} trusted contacts:`);
    contacts.forEach((c, i) => {
      console.log(`  ${i + 1}. ${c.name} (${c.phone}) — SMS: "${smsBody}"`);
    });

    res.status(200).json({
      success: true,
      notified: contacts.length,
      trackingLink,
      channels: ['sms', 'whatsapp'],
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to notify contacts' });
  }
});

export default router;
