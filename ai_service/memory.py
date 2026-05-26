import redis.asyncio as redis
import json
import logging
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)

class MemoryManager:
    def __init__(self, redis_url: str = "redis://redis:6379"):
        self.redis_url = redis_url
        self.redis_client = None

    async def connect(self):
        try:
            self.redis_client = redis.from_url(self.redis_url)
            logger.info("MemoryManager connected to Redis")
        except Exception as e:
            logger.error(f"MemoryManager failed to connect to Redis: {e}")

    def _get_key(self, incident_id: str) -> str:
        return f"memory:incident:{incident_id}"

    async def save_context(self, incident_id: str, context: Dict[str, Any], ttl_seconds: int = 86400):
        if not self.redis_client:
            return
            
        key = self._get_key(incident_id)
        
        # Fetch existing, update, and save
        existing = await self.get_context(incident_id) or {}
        existing.update(context)
        
        await self.redis_client.set(key, json.dumps(existing), ex=ttl_seconds)
        logger.debug(f"Saved memory context for {incident_id}")

    async def get_context(self, incident_id: str) -> Optional[Dict[str, Any]]:
        if not self.redis_client:
            return None
            
        key = self._get_key(incident_id)
        data = await self.redis_client.get(key)
        
        if data:
            return json.loads(data)
        return None

    async def close(self):
        if self.redis_client:
            await self.redis_client.close()

memory_manager = MemoryManager()
