"""
AI-Powered Cloud Troubleshooting Assistant
Capstone Project - AWS CAIP Certification
Stack: Amazon Bedrock (Nova Lite) + S3 Vectors Knowledge Base + Streamlit
"""

import streamlit as st
import boto3
import json
import os
from datetime import datetime

#### Page config #################################################################
st.set_page_config(
    page_title="Cloud Troubleshooting Assistant",
    page_icon="🔧",
    layout="wide",
)

#####Constants #################################################################
REGION          = "us-east-1"
MODEL_ID        = "amazon.nova-lite-v1:0"
KB_ID_FILE      = "setup/knowledge_base_id.txt"  

######Helpers #################################################################

def load_kb_id():
    """Read the Knowledge Base ID written by the setup script."""
    if os.path.exists(KB_ID_FILE):
        with open(KB_ID_FILE) as f:
            return f.read().strip() or None
    return None


def get_bedrock_client():
    return boto3.client("bedrock-agent-runtime", region_name=REGION)


def query_knowledge_base(client, kb_id: str, question: str) -> str:
    """
    Call Bedrock RetrieveAndGenerate using the S3-Vectors-backed Knowledge Base.
    Returns the generated answer text.
    """
    response = client.retrieve_and_generate(
        input={"text": question},
        retrieveAndGenerateConfiguration={
            "type": "KNOWLEDGE_BASE",
            "knowledgeBaseConfiguration": {
                "knowledgeBaseId": kb_id,
                "modelArn": f"arn:aws:bedrock:{REGION}::foundation-model/{MODEL_ID}",
                "retrievalConfiguration": {
                    "vectorSearchConfiguration": {"numberOfResults": 5}
                },
                "generationConfiguration": {
                    "promptTemplate": {
                        "textPromptTemplate": (
                            "You are an expert AWS cloud troubleshooting assistant. "
                            "Use ONLY the provided context to answer the question. "
                            "Be specific, structured, and list actionable steps. "
                            "If the context does not contain enough information, say so clearly.\n\n"
                            "$search_results$\n\n"
                            "Question: $query$"
                        )
                    }
                },
            },
        },
    )
    return response["output"]["text"]


def query_bedrock_direct(question: str) -> str:
    """
    Fallback: call Nova Lite directly (no Knowledge Base) so the app
    still works during setup or if the KB ID is not yet available.
    """
    client = boto3.client("bedrock-runtime", region_name=REGION)
    body = json.dumps({
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "text": (
                            "You are an expert AWS cloud troubleshooting assistant. "
                            "Answer the following question with specific, actionable steps. "
                            f"Question: {question}"
                        )
                    }
                ],
            }
        ],
        "inferenceConfig": {"maxTokens": 1024, "temperature": 0.3},
    })
    response = client.invoke_model(modelId=MODEL_ID, body=body)
    result   = json.loads(response["body"].read())
    return result["output"]["message"]["content"][0]["text"]


######Sidebar #################################################################
with st.sidebar:
    st.image("https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg", width=120)
    st.title("⚙️ Configuration")

    kb_id = load_kb_id()
    if kb_id:
        st.success(f"✅ Knowledge Base connected\n\n`{kb_id}`")
        use_kb = True
    else:
        st.warning(
            "⚠️ Knowledge Base not configured.\n\n"
            "Run `setup/01_setup_aws.py` first, then restart the app.\n\n"
            "Running in **Direct Bedrock** mode for now."
        )
        use_kb = False

    st.divider()
    st.markdown("**Model:** Amazon Nova Lite")
    st.markdown("**Region:** us-east-1")
    st.markdown("**Vector Store:** Amazon S3 Vectors")
    st.divider()

    st.markdown("### 💡 Example Questions")
    examples = [
        "Why can't my EC2 instance reach the internet?",
        "Why is my Apache vhost not loading?",
        "My S3 bucket is returning 403 Access Denied. How do I fix it?",
        "EC2 instance is unreachable via SSH. What should I check?",
        "Lambda function is timing out. How do I troubleshoot?",
    ]
    for ex in examples:
        if st.button(ex, use_container_width=True):
            st.session_state["prefill"] = ex

    st.divider()
    if st.button("🗑️ Clear Chat History", use_container_width=True):
        st.session_state["messages"] = []
        st.rerun()


######Main layout #################################################################
st.title("🔧 AI-Powered Cloud Troubleshooting Assistant")
st.markdown(
    "Ask any AWS infrastructure or networking question. "
    "The assistant uses your troubleshooting knowledge base to provide "
    "step-by-step diagnostic guidance."
)
st.divider()

# Chat history
if "messages" not in st.session_state:
    st.session_state["messages"] = []

# Render existing messages
for msg in st.session_state["messages"]:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        if msg["role"] == "assistant":
            st.caption(f"🕐 {msg.get('timestamp', '')}")

# Input — prefill from sidebar button or typed
prefill = st.session_state.pop("prefill", "")
user_input = st.chat_input("Describe your cloud issue...") or prefill

if user_input:
    # Show user message
    with st.chat_message("user"):
        st.markdown(user_input)
    st.session_state["messages"].append({"role": "user", "content": user_input})

    # Generate response
    with st.chat_message("assistant"):
        with st.spinner("Analyzing your issue..."):
            try:
                if use_kb:
                    client   = get_bedrock_client()
                    response = query_knowledge_base(client, kb_id, user_input)
                    source   = "📚 Knowledge Base + Nova Lite"
                else:
                    response = query_bedrock_direct(user_input)
                    source   = "🤖 Nova Lite (direct)"

                st.markdown(response)
                ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                st.caption(f"🕐 {ts}  |  {source}")

                st.session_state["messages"].append({
                    "role":      "assistant",
                    "content":   response,
                    "timestamp": ts,
                })

            except Exception as e:
                err = f"❌ Error: {str(e)}"
                st.error(err)
                st.info(
                    "Make sure your AWS credentials are configured "
                    "and Bedrock model access is enabled in us-east-1."
                )
