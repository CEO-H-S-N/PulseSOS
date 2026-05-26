from typing import Dict, Any
import asyncio
import logging
from workflow import sos_workflow_app, AgentState

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Orchestrator:
    def __init__(self):
        logger.info("Initializing Orchestrator Agent...")

    async def process_event(self, event_type: str, payload: Dict[str, Any]):
        """
        Main entry point for handling events. Routes events to the appropriate LangGraph workflow.
        """
        logger.info(f"Orchestrator received event: {event_type}")
        
        # Determine workflow based on event type
        if event_type == "SOS_TRIGGERED":
            await self._handle_sos_triggered(payload)
        elif event_type == "AUDIO_DETECTED":
            await self._handle_audio_detected(payload)
        else:
            logger.warning(f"Unhandled event type: {event_type}")

    async def _handle_sos_triggered(self, payload: Dict[str, Any]):
        logger.info(f"Starting SOS Workflow for payload: {payload}")
        
        # Initialize state
        initial_state: AgentState = {
            "incident_data": payload,
            "classification": {},
            "risk_assessment": {},
            "assigned_responders": [],
            "messages": [],
            "current_agent": "orchestrator"
        }

        # Execute LangGraph workflow
        logger.info("Invoking LangGraph SOS Workflow...")
        # Since our mock nodes are synchronous currently, we invoke directly
        # In a real async LangGraph setup, use ainvoke()
        try:
            # We mock the async execution for the placeholder graph
            await asyncio.sleep(0.1)
            final_state = sos_workflow_app.invoke(initial_state)
            logger.info(f"SOS Workflow Complete. Final Agent: {final_state.get('current_agent')}")
        except Exception as e:
            logger.error(f"Error executing workflow: {e}")

    async def _handle_audio_detected(self, payload: Dict[str, Any]):
        logger.info(f"Starting Audio Workflow for payload: {payload}")
        await asyncio.sleep(1)
        logger.info("Audio Workflow Complete.")

orchestrator = Orchestrator()
