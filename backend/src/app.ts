import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import incidentRoutes from './routes/incidentRoutes';
import authRoutes from './routes/authRoutes';
import contactRoutes from './routes/contactRoutes';
import mediaRoutes from './routes/mediaRoutes';
import analyticsRoutes from './routes/analyticsRoutes';
import aiRoutes from './routes/aiRoutes';

const app = express();

// Secure server with HTTP header protections
app.use(helmet());

// Cross-Origin Resource Sharing setup
app.use(cors({
  origin: '*', // Open connectivity for cross-platform app local servers
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));

// Request payload limit controls
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Standardized HTTP traffic logs
app.use(morgan('dev'));

// Rate limiting to block API scraping / Denial of Service
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes window
  max: 100, // Limit each IP address to 100 API hits per window
  message: { error: 'Too many requests from this IP. Please try again after 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Map API Route Endpoints
app.use('/api/auth', authRoutes);
app.use('/api/incidents', incidentRoutes);
app.use('/api/contacts', contactRoutes);
app.use('/api/media', mediaRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/ai', aiRoutes);

// Base sanity check landing route
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    network: 'PulseSOS Community Alert Gateway v1.0.0'
  });
});

// Graceful global error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('❌ Express Boundary Error caught:', err);
  res.status(500).json({ error: 'Internal Server Error caught in Express Gateway' });
});

export default app;
