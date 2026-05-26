from typing import Dict, Any
import logging
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
import json

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from llm_factory import llm_instance

logger = logging.getLogger(__name__)

class IncidentSummarizationAgent:
    def __init__(self):
        logger.info("Initializing Incident Summarization Agent...")
        self.llm = llm_instance
        self.parser = StrOutputParser()
        self.prompt = PromptTemplate(
            template="""You are a 911 emergency dispatcher AI.
Write a very concise (1-2 sentences), highly actionable summary of the ongoing incident for responders.

Incident Data:
{incident_data}

Context History:
{memory_context}

Summary:""",
            input_variables=["incident_data", "memory_context"],
        )
        self.chain = self.prompt | self.llm | self.parser

    async def summarize(self, incident_data: Dict[str, Any], memory_context: Dict[str, Any]) -> str:
        """
        Generate concise NLP summaries for responders, contacts, police.
        """
        logger.info(f"Summarizing incident: {incident_data.get('id', 'unknown')}")
        
        try:
            result = await self.chain.ainvoke({
                "incident_data": json.dumps(incident_data),
                "memory_context": json.dumps(memory_context)
            })
            return result.strip()
        except Exception as e:
            logger.error(f"Summarization failed, using fallback: {e}")
            return "Active emergency reported. Proceed with caution."

incident_summarization_agent = IncidentSummarizationAgent()
