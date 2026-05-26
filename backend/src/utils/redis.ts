import { createClient } from 'redis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

const redisPublisher = createClient({ url: redisUrl });

redisPublisher.on('error', (err) => console.log('Redis Publisher Error', err));
redisPublisher.on('connect', () => console.log('✅ Connected to Redis (Publisher)'));

export const connectRedis = async () => {
    try {
        await redisPublisher.connect();
    } catch (e) {
        console.error('Failed to connect to Redis', e);
    }
};

export const publishEvent = async (channel: string, message: any) => {
    try {
        if (!redisPublisher.isOpen) {
            await redisPublisher.connect();
        }
        await redisPublisher.publish(channel, JSON.stringify(message));
    } catch (error) {
        console.error(`Error publishing to ${channel}:`, error);
    }
};
