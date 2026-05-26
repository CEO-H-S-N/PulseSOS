import redis.asyncio as redis
import json
import asyncio
import logging
from typing import Callable, Awaitable

logger = logging.getLogger(__name__)

class EventBus:
    def __init__(self, redis_url: str = "redis://redis:6379"):
        self.redis_url = redis_url
        self.redis_client = None
        self.pubsub = None

    async def connect(self):
        try:
            self.redis_client = redis.from_url(self.redis_url)
            self.pubsub = self.redis_client.pubsub()
            logger.info(f"Connected to Redis at {self.redis_url}")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")

    async def publish(self, channel: str, message: dict):
        if self.redis_client:
            await self.redis_client.publish(channel, json.dumps(message))
            logger.debug(f"Published to {channel}: {message}")

    async def subscribe(self, channel: str, callback: Callable[[dict], Awaitable[None]]):
        if self.pubsub:
            await self.pubsub.subscribe(channel)
            logger.info(f"Subscribed to channel: {channel}")
            
            # Start listening loop in background
            asyncio.create_task(self._listen(channel, callback))

    async def _listen(self, channel: str, callback: Callable[[dict], Awaitable[None]]):
        try:
            async for message in self.pubsub.listen():
                if message['type'] == 'message':
                    data = json.loads(message['data'])
                    await callback(data)
        except asyncio.CancelledError:
            logger.info(f"Stopped listening to {channel}")
        except Exception as e:
            logger.error(f"Error in Redis listener: {e}")

    async def close(self):
        if self.pubsub:
            await self.pubsub.close()
        if self.redis_client:
            await self.redis_client.close()

event_bus = EventBus()
