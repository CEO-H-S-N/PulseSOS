import logging
from langchain_openai import ChatOpenAI
from langchain_google_genai import ChatGoogleGenerativeAI
import sys
import os

# Assuming config is in the same directory
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import settings

logger = logging.getLogger(__name__)

def get_llm():
    """
    Returns a configured LangChain Chat Model instance based on settings.
    """
    provider = settings.LLM_PROVIDER.lower()
    
    if provider == "openai":
        if not settings.OPENAI_API_KEY:
            logger.warning("OPENAI_API_KEY is not set. Defaulting to empty key for dev/mocking.")
        return ChatOpenAI(
            model="gpt-4o",
            temperature=settings.LLM_TEMPERATURE,
            max_tokens=settings.LLM_MAX_TOKENS,
            openai_api_key=settings.OPENAI_API_KEY or "sk-mock-key"
        )
    elif provider == "google":
        if not settings.GOOGLE_API_KEY:
            logger.warning("GOOGLE_API_KEY is not set. Defaulting to empty key for dev/mocking.")
        return ChatGoogleGenerativeAI(
            model=settings.LLM_MODEL,
            temperature=settings.LLM_TEMPERATURE,
            max_tokens=settings.LLM_MAX_TOKENS,
            google_api_key=settings.GOOGLE_API_KEY or "mock-key"
        )
    else:
        raise ValueError(f"Unsupported LLM provider: {provider}")

# Singleton-ish pattern for reuse
llm_instance = get_llm()
