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

class Coordinates(BaseModel):
    lat: float
    lng: float

class Recommendation(BaseModel):
    type: str = Field(description="Type of recommendation (e.g., safe_zone, hospital, police_station).")
    title: str = Field(description="Short, actionable title.")
    description: str = Field(description="Detailed instructions.")
    coordinates: Coordinates = Field(description="Lat/Lng coordinates of the recommended location.")

class RecommendationOutput(BaseModel):
    recommendations: List[Recommendation]

class SafetyRecommendationAgent:
    def __init__(self):
        logger.info("Initializing Safety Recommendation Agent...")
        self.llm = llm_instance
        self.parser = PydanticOutputParser(pydantic_object=RecommendationOutput)
        self.prompt = PromptTemplate(
            template="""You are a tactical emergency routing AI.
Based on the incident data, suggest 1-2 immediate safe zones or critical locations for the victim.

Incident Data:
{incident_data}

{format_instructions}
""",
            input_variables=["incident_data"],
            partial_variables={"format_instructions": self.parser.get_format_instructions()},
        )
        self.chain = self.prompt | self.llm | self.parser

    async def generate_recommendations(self, incident_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Provide real-time recommendations (nearest hospital, safe route, etc.)
        """
        logger.info(f"Generating safety recommendations for incident: {incident_data.get('id', 'unknown')}")
        
        try:
            result = await self.chain.ainvoke({"incident_data": json.dumps(incident_data)})
            return [rec.model_dump() for rec in result.recommendations]
        except Exception as e:
            logger.error(f"Recommendation failed, using fallback: {e}")
            return [
                {
                    "type": "safe_zone",
                    "title": "Move to a Well-Lit Area",
                    "description": "Proceed to the nearest public space.",
                    "coordinates": {"lat": 0.0, "lng": 0.0}
                }
            ]

safety_recommendation_agent = SafetyRecommendationAgent()
