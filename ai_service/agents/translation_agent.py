from typing import Dict, Any
import logging
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from llm_factory import llm_instance

logger = logging.getLogger(__name__)

class TranslationAgent:
    def __init__(self):
        logger.info("Initializing Translation Agent...")
        self.llm = llm_instance
        self.parser = StrOutputParser()
        self.prompt = PromptTemplate(
            template="""Translate the following text to {target_language}.
Do not add any additional conversational filler. Only return the translated text.

Text to translate:
{text}

Translation:""",
            input_variables=["text", "target_language"],
        )
        self.chain = self.prompt | self.llm | self.parser

    async def translate(self, text: str, target_language: str) -> str:
        """
        Support multilingual communication.
        """
        logger.info(f"Translating text to {target_language}...")
        
        try:
            result = await self.chain.ainvoke({
                "text": text,
                "target_language": target_language
            })
            return result.strip()
        except Exception as e:
            logger.error(f"Translation failed, using fallback: {e}")
            return f"[Translated to {target_language}] {text}"

translation_agent = TranslationAgent()
