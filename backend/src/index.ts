import http from 'http';
import { Server } from 'socket.io';
import app from './app';
import { setupIncidentSockets } from './sockets/incidentSocket';
import { connectRedis } from './utils/redis';
import * as dotenv from 'dotenv';

dotenv.config();

const PORT = process.env.PORT || 5000;

// Create standard HTTP server around the Express application
const server = http.createServer(app);

// Bind Socket.IO engine to the HTTP server instance
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Initialize real-time emergency events channels
setupIncidentSockets(io);

// Initialize Redis Pub/Sub connection for AI Service events
connectRedis();

// Boot Server listener
server.listen(PORT, () => {
  console.log(`
  🚀 PulseSOS Network Gateway Listening...
  🔊 API Server URL:  http://localhost:${PORT}
  🔌 Socket Gateway:   ws://localhost:${PORT}
  🟢 System status:   HEALTHY
  `);
});

// Handle server termination events gracefully
process.on('SIGTERM', () => {
  console.log('🛑 SIGTERM received. Shutting down real-time gateway gracefully...');
  server.close(() => {
    console.log('✅ Real-time gateway closed.');
    process.exit(0);
  });
});
