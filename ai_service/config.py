"""
PulseSOS AI Service — Configuration
Centralized settings with environment variable overrides.
"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # ─── Service ─────────────────────────────────────────────
    SERVICE_NAME: str = "pulsesos-ai-orchestrator"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # ─── Redis ───────────────────────────────────────────────
    REDIS_URL: str = "redis://localhost:6379"
    REDIS_EVENT_CHANNEL: str = "pulsesos:events"
    REDIS_MEMORY_TTL: int = 3600  # 1 hour session memory

    # ─── LLM Provider ────────────────────────────────────────
    LLM_PROVIDER: str = "google"  # "openai" | "google"
    OPENAI_API_KEY: Optional[str] = None
    GOOGLE_API_KEY: Optional[str] = None
    LLM_MODEL: str = "gemini-2.0-flash"
    LLM_TEMPERATURE: float = 0.3
    LLM_MAX_TOKENS: int = 2048

    # ─── Backend Integration ─────────────────────────────────
    BACKEND_URL: str = "http://localhost:5000"
    BACKEND_AUTH_TOKEN: str = "Bearer dev"

    # ─── Agent Orchestration ─────────────────────────────────
    ORCHESTRATOR_TIMEOUT: int = 10  # seconds
    MAX_AGENT_RETRIES: int = 3
    CIRCUIT_BREAKER_THRESHOLD: int = 5
    CIRCUIT_BREAKER_RESET: int = 60  # seconds

    # ─── Audio Processing ────────────────────────────────────
    WHISPER_MODEL: str = "base"  # tiny | base | small
    AUDIO_CHUNK_DURATION: int = 5  # seconds

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
