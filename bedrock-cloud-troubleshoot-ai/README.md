# 🔧 AI-Powered Cloud Troubleshooting Assistant

**AWS CAIP Capstone Project**

A conversational AI assistant that helps diagnose AWS and Linux infrastructure
issues using a Retrieval-Augmented Generation (RAG) architecture.

---

## Architecture

```
User (Streamlit UI)
        │
        |
Amazon Bedrock
(Nova Lite — RetrieveAndGenerate API)
        │
        ├──> Bedrock Knowledge Base
        │           │
        │           V
        │    Amazon S3 Vectors  <── Titan Embed v2 (embeddings)
        │    (vector store)
        │
        └──> S3 Docs Bucket
             (troubleshooting docs)
```

**Key design decision:** S3 Vectors is used as the vector store instead of
Amazon OpenSearch Serverless. OpenSearch Serverless charges a minimum of ~$350/month
regardless of usage. S3 Vectors is pay-per-use and costs nearly nothing for
a Capstone-scale project.

---

## AWS Services Used

| Service | Purpose | Cost |
|---|---|---|
| Amazon Bedrock (Nova Lite) | LLM inference + RetrieveAndGenerate | Cost per token equals (~$0.001 per query) |
| Bedrock Knowledge Base | RAG orchestration | Free (pay for underlying services) |
| Amazon S3 Vectors | Vector embedding storage | Cost per use equals (pennies for this project) |
| Titan Embed Text v2 | Generates embeddings from docs | Cost per token use is (minimal) |
| Amazon S3 (standard) | Stores troubleshooting documents | Free tier (5 GB) |
| AWS IAM | Role based access for Bedrock | Free |
| Streamlit | Front-end UI (runs locally) | Free |

**Estimated total cost for Capstone build + demo: < $2.00**

---

## Project Structure

```
cloud_troubleshoot_ai/
├── src/
│   └── app.py                    # Streamlit front-end application
├── setup/
│   ├── 03_sync_knowledge_base.py # Optional script to re-trigger sync
│   ├── 04_cleanup.py             # Deletes all resources after demo
│   └── knowledge_base_id.txt     # Manually created — stores KB ID
├── docs/                         # Troubleshooting documents uploaded to S3
│   ├── ec2_internet_connectivity.txt
│   ├── apache_vhost_not_loading.txt
│   ├── s3_403_access_denied.txt
│   ├── ec2_ssh_unreachable.txt
│   └── lambda_timeout.txt
├── requirements.txt
└── README.md
```

---

## Prerequisites

1. **AWS CLI configured** with valid credentials:
   ```bash
   aws configure
   # Enter Access Key ID, Secret Access Key, region: us-east-1, output: json
   # Important: type keys manually from  downloaded CSV — do not copy/paste
   ```

2. **Bedrock model access**  no manual activation needed. As of 2025, AWS
   automatically enables serverless foundation models on first invocation.
   Nova Lite and Titan Embed v2 activate the first time the code calls them.

3. **Python 3.10+** installed 

4. **Virtual environment** set up inside the project folder

---

## Part 1 : AWS Console Setup (Manual GUI Provisioning)

All AWS resources were provisioned manually through the AWS Console.

---

### Step 1 : Create the S3 Docs Bucket

1. Go to AWS Console -> search **S3** -> click **Create bucket**
2. **Bucket name:** `cloud-troubleshoot-docs-capstone`
3. **Region:** us-east-1
4. Leave **Block all public access** checked (default)
5. Leave all other settings as default
6. Click **Create bucket**

Upload the troubleshooting documents:

1. Click on `cloud-troubleshoot-docs-capstone`
2. Click **Create folder** -> name it `docs` → click **Create folder**
3. Click into the `docs` folder
4. Click **Upload** -> **Add files**
5. Select all 5 `.txt` files from my local `docs/` folder
6. Click **Upload**

---

### Step 2 : Create the S3 Vectors Bucket

1. In the S3 console, click **Vector buckets** in the left sidebar
2. Click **Create vector bucket**
3. **Bucket name:** `cloud-troubleshoot-vectors-capstone`
4. **Region:** us-east-1
5. Click **Create vector bucket**

---

### Step 3 : Create the IAM Role for Bedrock

1. Go to AWS Console -> search **IAM** -> click **Roles** → **Create role**
2. **Trusted entity type:** AWS service
3. **Service:** Bedrock
4. **Use case:** Amazon Bedrock Agentcore (only available Bedrock option in console)
5. Click **Next** -> skip permissions for now -> click **Next**
6. **Role name:** `BedrockKBRole-capstone`
7. Click **Create role**

**Update the Trust Policy:**

1. Find `BedrockKBRole-capstone` and click on it
2. Click the **Trust relationships** tab -> **Edit trust policy**
3. Replace the entire policy with this:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccessToBedrock",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "AllowAccessToBedrockAgentcore",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock-agentcore.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

4. Click **Update policy**

**Add the Inline Policy:**

1. Click the **Permissions** tab -> **Add permissions** → **Create inline policy**
2. Click the **JSON** tab and paste this replacing `YOUR_ACCOUNT_ID` with your
   12-digit AWS account ID (found in the top right corner of the console):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3DocsRead",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::cloud-troubleshoot-docs-capstone",
        "arn:aws:s3:::cloud-troubleshoot-docs-capstone/*"
      ]
    },
    {
      "Sid": "S3VectorsAccess",
      "Effect": "Allow",
      "Action": [
        "s3vectors:CreateIndex",
        "s3vectors:DeleteIndex",
        "s3vectors:GetIndex",
        "s3vectors:ListIndexes",
        "s3vectors:PutVectors",
        "s3vectors:GetVectors",
        "s3vectors:DeleteVectors",
        "s3vectors:QueryVectors"
      ],
      "Resource": "*"
    },
    {
      "Sid": "BedrockEmbedding",
      "Effect": "Allow",
      "Action": "bedrock:InvokeModel",
      "Resource": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
    }
  ]
}
```

> **Note:** The S3 Vectors Resource is set to `"*"` because Bedrock creates its
> own internal S3 Vectors bucket during Knowledge Base provisioning. Restricting
> to a named bucket ARN causes a 403 error during Knowledge Base creation.

3. Click **Next** ->  **Policy name:** `BedrockKBInlinePolicy-capstone` -> **Create policy**

---

### Step 4 : Create the Bedrock Knowledge Base

1. Go to AWS Console -> search **Bedrock** -> click **Knowledge bases** in the left sidebar
2. Click **Create knowledge base**
3. Select **Unstructured data** -> **Knowledge base with vector store**
4. **Knowledge base name:** `cloud-troubleshoot-kb`
5. **Description:** `Cloud troubleshooting KB backed by S3 Vectors`
6. **IAM role:** select **Use an existing role** -> choose `BedrockKBRole-capstone`
7. Click **Next**

**Configure data source:**

1. **Data source name:** `cloud-troubleshoot-docs`
2. **Data source type:** Amazon S3
3. **S3 URI:** click **Browse S3** -> select `cloud-troubleshoot-docs-capstone`
4. Click **Next**

**Configure vector store:**

1. **Embeddings model:** Titan Embed Text v2
2. **Vector store:** Amazon S3 Vectors
3. **Vector bucket:** select `cloud-troubleshoot-vectors-capstone`
4. Click **Next** -> review -> click **Create knowledge base**

Wait for status to show **Available** (1–2 minutes).

---

### Step 5 : Sync the Data Source

1. Click on `cloud-troubleshoot-kb`
2. Scroll down to **Data sources**
3. Check the box next to `cloud-troubleshoot-docs`
4. Click **Sync**

Wait for sync status to show **Ready** (2–5 minutes).

---

## Part 2 : Local Environment Setup

### Step 1 : Create the project folder

```bash
cd ~/Desktop/Caip_Project/Capstone_project
mkdir cloud_troubleshoot_ai
cd cloud_troubleshoot_ai
mkdir src setup docs
```

### Step 2 : Create and activate a virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
```

The terminal prompt should show `(venv)` at the beginning.

### Step 3 : Install dependencies

```bash
pip3 install -r requirements.txt
```

### Step 4 : Configure AWS credentials

```bash
aws configure
```

Enter the following when prompted:
- **AWS Access Key ID:** from the downloaded CSV
- **AWS Secret Access Key:** from the downloaded CSV
- **Default region:** us-east-1
- **Default output format:** json

> **Important:** Type the keys manually from the CSV file: do not copy and paste
> to avoid SignatureDoesNotMatch errors.

### Step 5 : Save the Knowledge Base ID

1. In the Bedrock console click on `cloud-troubleshoot-kb`
2. Copy the **Knowledge base ID** (example: `VIER2ESTBQ`)
3. Save it to the project:

```bash
echo "YOUR_KB_ID" > setup/knowledge_base_id.txt
```

Verify it saved:

```bash
cat setup/knowledge_base_id.txt
```

### Step 6 : Place the project files

Copy the following files into the correct folders:

- `src/app.py` → inside the `src/` folder
- All 5 `.txt` troubleshooting docs → inside the `docs/` folder
- `requirements.txt` → in the root project folder

### Step 7 : Launch the app

```bash
streamlit run src/app.py
```

Press **Enter** to skip the Streamlit email prompt. The browser will open
automatically to `http://localhost:8501`.

The sidebar should show:
- ✅ Knowledge Base connected
- Your Knowledge Base ID
- Model: Amazon Nova Lite
- Region: us-east-1
- Vector Store: Amazon S3 Vectors

---

## Demo Script (Capstone Presentation)



1. **"Why can't my EC2 instance reach the internet?"**
   → Demonstrates VPC/IGW/route table troubleshooting

2. **"Why is my Apache vhost not loading?"**
   → Demonstrates Linux + web server troubleshooting

3. **"My S3 bucket is returning 403 Access Denied. How do I fix it?"**
   → Demonstrates IAM + bucket policy troubleshooting

4. **"EC2 instance is unreachable via SSH. What should I check?"**
   → Demonstrates security group + key pair troubleshooting

5. **"Lambda function is timing out. How do I troubleshoot?"**
   → Demonstrates serverless troubleshooting

---

## Cleanup (Run after my demo)

```bash
python3 setup/04_cleanup.py
```

Or delete manually through the AWS Console in this order:
1. Bedrock Knowledge Base → delete data source first, then the Knowledge Base
2. S3 Vectors bucket
3. S3 docs bucket (empty it first, then delete)
4. IAM role -> delete inline policy first, then the role

---

## Presentation Talking Points

**What I built:**
An AI-powered troubleshooting assistant that uses Retrieval Augmented Generation
to answer cloud infrastructure questions. Instead of generic LLM responses, it
retrieves specific guidance from a curated knowledge base of real troubleshooting
scenarios built from my own lab experience.

**My architecture decisions:**
- Chose S3 Vectors over OpenSearch Serverless to avoid the $350/month minimum cost
- Used Nova Lite for cost efficiency the cheapest Bedrock model with strong reasoning
- Streamlit for rapid UI development with minimal frontend code
- Provisioned all AWS resources manually through the console for hands-on learning

**What challenged me:**
- The IAM console no longer shows a Bedrock Knowledge Base use case had to select
  AgentCore and manually update the trust policy to add bedrock.amazonaws.com
- The S3 Vectors IAM resource ARN had to be set to wildcard because Bedrock creates
  its own internal vector bucket during Knowledge Base provisioning restricting
  to a named bucket caused a 403 error
- Finding the virtual environment after it was created in a different directory

**What I learned:**
- RAG architecture using Bedrock Knowledge Bases
- S3 Vectors as a cost-effective alternative to managed vector databases
- How to chain Bedrock services: Titan Embed to S3 Vectors to Nova Lite
- How to read and fix IAM trust policies and inline policies
- How to troubleshoot AWS permission errors from ARN level error messages
