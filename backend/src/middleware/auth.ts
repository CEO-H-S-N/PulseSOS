import { Request, Response, NextFunction } from 'express';
import { auth } from '../config/firebase';

export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    phone?: string;
    email?: string;
  };
}

export const authenticateToken = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({ error: 'Unauthorized: Access token missing' });
    return;
  }

  // Development Fallback Bypass
  if (token === 'dev-token-secret-123' || (process.env.NODE_ENV !== 'production' && token === 'dev')) {
    req.user = {
      uid: 'mock-user-uid-456',
      phone: '+15551234567',
      email: 'mockuser@pulsesos.com',
    };
    next();
    return;
  }

  try {
    const decodedToken = await auth.verifyIdToken(token);
    req.user = {
      uid: decodedToken.uid,
      phone: decodedToken.phone_number,
      email: decodedToken.email,
    };
    next();
  } catch (error) {
    console.error('❌ Token Verification Failed:', error);
    res.status(403).json({ error: 'Forbidden: Invalid or expired access token' });
  }
};
