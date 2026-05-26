from typing import Dict, Any
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

class RiskAssessmentOutput(BaseModel):
    urgency_level: int = Field(description="Urgency level on a scale of 1 to 5, where 5 is the highest urgency.")
    victim_risk_score: float = Field(description="Victim risk score between 0.0 and 1.0.")
    escalation_needed: bool = Field(description="True if the incident needs immediate escalation to authorities.")
    threat_probability: str = Field(description="Threat probability: low, medium, or high.")

class RiskAssessmentAgent:
    def __init__(self):
        logger.info("Initializing Risk Assessment Agent...")
        self.llm = llm_instance
        self.parser = PydanticOutputParser(pydantic_object=RiskAssessmentOutput)
        self.prompt = PromptTemplate(
            template="""You are an expert emergency risk assessor.
Analyze the incident data and its classification to determine the risk level.

Incident Data:
{incident_data}

Classification:
{classification}

{format_instructions}
""",
            input_variables=["incident_data", "classification"],
            partial_variables={"format_instructions": self.parser.get_format_instructions()},
        )
        self.chain = self.prompt | self.llm | self.parser

    async def assess(self, incident_data: Dict[str, Any], classification: Dict[str, Any]) -> Dict[str, Any]:
        """
        Determine urgency level, victim risk score, and threat probability.
        """
        logger.info(f"Assessing risk for incident: {incident_data.get('id', 'unknown')}")
        
        try:
            result = await self.chain.ainvoke({
                "incident_data": json.dumps(incident_data),
                "classification": json.dumps(classification)
            })
            return result.model_dump()
        except Exception as e:
            logger.error(f"Risk assessment failed, using fallback: {e}")
            return {
                "urgency_level": 4,
                "victim_risk_score": 0.8,
                "escalation_needed": True,
                "threat_probability": "high"
            }

risk_assessment_agent = RiskAssessmentAgent()
