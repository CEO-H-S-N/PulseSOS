import { Router, Request, Response } from 'express';
// Note: Requires node-fetch or similar for HTTP calls if not natively supported by Node version, 
// using native fetch for Node >= 18.
const router = Router();

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://ai_service:8000';

// Proxy endpoint to trigger an AI workflow manually (optional, mostly driven by Redis)
router.post('/trigger', async (req: Request, res: Response) => {
  try {
    const { event_type, payload } = req.body;
    
    const response = await fetch(`${AI_SERVICE_URL}/api/ai/event`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ event_type, payload })
    });
    
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Error proxying to AI service:', error);
    res.status(500).json({ error: 'AI Service is currently unavailable.' });
  }
});

// Proxy endpoint to get AI insights for an incident
router.get('/insights/:incidentId', async (req: Request, res: Response) => {
  try {
    const { incidentId } = req.params;
    
    // Assuming AI service exposes this endpoint
    const response = await fetch(`${AI_SERVICE_URL}/api/ai/insights/${incidentId}`);
    
    if (!response.ok) {
      return res.status(response.status).json({ error: 'Insights not found' });
    }
    
    const data = await response.json();
    res.status(200).json(data);
  } catch (error) {
    console.error('Error fetching insights from AI service:', error);
    res.status(500).json({ error: 'AI Service is currently unavailable.' });
  }
});

export default router;
