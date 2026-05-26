from typing import Dict, Any, List
import logging
from pydantic import BaseModel, Field
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
import json

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from llm_factory import llm_instance

logger = logging.getLogger(__name__)

class ClassificationOutput(BaseModel):
    classification: str = Field(description="The primary classification of the incident, e.g., robbery, medical, fire, accident, assault, harassment.")
    confidence_score: float = Field(description="Confidence score between 0.0 and 1.0.")
    severity: str = Field(description="Severity of the incident: low, medium, high, critical.")
    tags: List[str] = Field(description="List of relevant tags, e.g., 'requires_police', 'weapon_involved'.")

class ClassificationAgent:
    def __init__(self):
        logger.info("Initializing Classification Agent...")
        self.llm = llm_instance
        self.parser = PydanticOutputParser(pydantic_object=ClassificationOutput)
        self.prompt = PromptTemplate(
            template="""You are an expert emergency dispatcher AI. 
Analyze the following incident data and classify the emergency.

Incident Data:
{incident_data}

{format_instructions}
""",
            input_variables=["incident_data"],
            partial_variables={"format_instructions": self.parser.get_format_instructions()},
        )
        self.chain = self.prompt | self.llm | self.parser

    async def analyze(self, incident_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze trigger patterns, audio, text, metadata to classify incident.
        """
        logger.info(f"Classifying incident: {incident_data.get('id', 'unknown')}")
        
        try:
            # We mock actual LLM call for safety if API key is mock, but this is the real pipeline
            result = await self.chain.ainvoke({"incident_data": json.dumps(incident_data)})
            return result.model_dump()
        except Exception as e:
            logger.error(f"Classification failed, using fallback: {e}")
            # Fallback
            return {
                "classification": "unclassified",
                "confidence_score": 0.5,
                "severity": "high",
                "tags": ["urgent", "requires_review"]
            }

classification_agent = ClassificationAgent()
