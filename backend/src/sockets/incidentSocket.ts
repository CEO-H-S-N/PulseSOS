import { Server, Socket } from 'socket.io';
import { publishEvent } from '../utils/redis';

interface CoordinateUpdate {
  incidentId: string;
  latitude: number;
  longitude: number;
  accuracy?: number;
}

export const setupIncidentSockets = (io: Server): void => {
  io.on('connection', (socket: Socket) => {
    console.log(`🔌 Client connected to Real-Time safety gateway: ${socket.id}`);

    // Join specialized channel room for a specific emergency incident
    socket.on('joinIncident', (data: { incidentId: string; userId: string; role: string; name: string }) => {
      const { incidentId, userId, role, name } = data;
      const roomName = `incident-${incidentId}`;
      socket.join(roomName);
      
      console.log(`👤 User ${name} (${role}) joined emergency room: ${roomName}`);

      // Publish event to AI Orchestrator
      publishEvent('SOS_TRIGGERED', {
        incidentId,
        userId,
        role,
        name,
        timestamp: new Date().toISOString()
      });

      // Broadcast responder arrival update to victim and other helpers
      socket.to(roomName).emit('responderJoined', {
        userId,
        name,
        role,
        message: `${name} is responding to your emergency alert.`,
      });
    });

    // Handle high-frequency live GPS tracking coordinates stream
    socket.on('updateLocation', (data: CoordinateUpdate) => {
      const { incidentId, latitude, longitude, accuracy } = data;
      const roomName = `incident-${incidentId}`;
      
      // Publish movement event to AI Analytics & Assessment
      publishEvent('USER_MOVING', {
        incidentId,
        latitude,
        longitude,
        accuracy: accuracy || 0,
        timestamp: new Date().toISOString()
      });

      // Broadcast live movement details to active room participants
      socket.to(roomName).emit('locationUpdated', {
        latitude,
        longitude,
        accuracy: accuracy || 0,
        timestamp: new Date().toISOString(),
      });
    });

    // Leave incident channel on safety resolution
    socket.on('leaveIncident', (data: { incidentId: string; name: string }) => {
      const { incidentId, name } = data;
      const roomName = `incident-${incidentId}`;
      socket.leave(roomName);
      console.log(`🚪 User ${name} left emergency channel: ${roomName}`);
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Client disconnected from real-time gateway: ${socket.id}`);
    });
  });
};
