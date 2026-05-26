from typing import Dict, Any, List, TypedDict
from langgraph.graph import StateGraph, END
import logging

logger = logging.getLogger(__name__)

# Define the state for the workflow
class AgentState(TypedDict):
    incident_data: Dict[str, Any]
    classification: Dict[str, Any]
    risk_assessment: Dict[str, Any]
    assigned_responders: List[Dict[str, Any]]
    messages: List[str]
    current_agent: str

def create_sos_workflow() -> StateGraph:
    """
    Builds the LangGraph state graph for the SOS emergency workflow.
    """
    logger.info("Building SOS LangGraph workflow...")
    workflow = StateGraph(AgentState)

    # Define Node functions (these will call the actual agents)
    def call_classification(state: AgentState):
        logger.info("Node: Classification")
        return {"current_agent": "classification"}

    def call_risk_assessment(state: AgentState):
        logger.info("Node: Risk Assessment")
        return {"current_agent": "risk_assessment"}

    def call_responder_coordination(state: AgentState):
        logger.info("Node: Responder Coordination")
        return {"current_agent": "responder_coordination"}

    def call_emergency_contact(state: AgentState):
        logger.info("Node: Emergency Contact")
        return {"current_agent": "emergency_contact"}

    def call_summarization(state: AgentState):
        logger.info("Node: Incident Summarization")
        return {"current_agent": "incident_summarization"}

    # Add Nodes
    workflow.add_node("classification", call_classification)
    workflow.add_node("risk_assessment", call_risk_assessment)
    workflow.add_node("responder_coordination", call_responder_coordination)
    workflow.add_node("emergency_contact", call_emergency_contact)
    workflow.add_node("summarization", call_summarization)

    # Define Edges (Workflow Path)
    workflow.set_entry_point("classification")
    workflow.add_edge("classification", "risk_assessment")
    workflow.add_edge("risk_assessment", "responder_coordination")
    workflow.add_edge("responder_coordination", "emergency_contact")
    workflow.add_edge("emergency_contact", "summarization")
    workflow.add_edge("summarization", END)

    return workflow.compile()

# Instantiate the compiled graph
sos_workflow_app = create_sos_workflow()
