# Networking & Cloud Engineering Portfolio

Network engineer with 20 years in enterprise infrastructure, transitioning into cloud architecture and DevOps. This repo contains hands-on projects, automation tools, and labs built around AWS, Python, Bash, and Go.

The focus is practical work: real deployments, real problems, documented clearly.

---

## Projects

### AI-Powered Cloud Troubleshooting Assistant (`/bedrock-cloud-troubleshoot-ai`)

Built and deployed a conversational AI assistant using a RAG architecture on AWS. The assistant retrieves from a curated knowledge base of real troubleshooting scenarios and generates specific, grounded responses instead of generic LLM output.

Stack: Amazon Bedrock (Nova Lite), Bedrock Knowledge Base, S3 Vectors, Titan Embed v2, EC2, IAM, Streamlit, Python

Key decisions and blockers documented in the project README: IAM trust policy misconfiguration when the console no longer showed the Bedrock KB use case, S3 Vectors wildcard ARN required because Bedrock creates its own internal vector bucket during Knowledge Base provisioning, and Python virtual environment issues from creating it in the wrong directory.

---

### Highly Available Auto Scaling Web App (`/scalability-alb-autoscaling`)

CloudFormation template that deploys a fault-tolerant web application across three availability zones, fronted by an Application Load Balancer and backed by an Auto Scaling group. The entire environment builds from one file.

Stack: CloudFormation, VPC, ALB, Auto Scaling, EC2, IAM, CloudWatch

Full write-up on Medium: [From Two Servers to Three Under Load: Auto Scaling on AWS](https://medium.com/@SouthGA_CloudEngineer/from-two-servers-to-three-under-load-auto-scaling-on-aws-3cda70c921b1)

---

### Go TCP Network Checker (`/golang-network-projects`)

TCP connectivity checker built in Go, versioned to show progression. v1 does a basic single-port check; v2 adds a custom struct, multi-port scanning, response timing, and file output. Exits with a non-zero code on failure, which makes it usable in CI/CD pipelines.

Stack: Go, TCP socket programming, file I/O

---

### Python Grade Tracker with Boto3/S3 (`/python-complete-project`)

Python CLI application that integrates Boto3 and AWS S3 for cloud-based data persistence. Demonstrates AWS SDK usage, file I/O, and structured program design across multiple iterations.

Stack: Python, Boto3, AWS S3

---

### Apache Automation (`/apache-automation-project`)

Bash scripts that automate Apache web server deployment on Ubuntu Linux: package install, service management, HTML content deployment, and permission hardening. Written for repeatable, idempotent execution.

Stack: Bash, Apache, Linux

---

### Labs (`/labs/level-up-it`)

Hands-on Linux and infrastructure labs:

- Deploy Apache web server from scratch (scripted)
- Apache virtual host troubleshooting (scripted fix)
- DokuWiki deployment on Linux (milestone project)

---

## Tech Used

| Area | Tools |
|---|---|
| Cloud | AWS EC2, S3, Bedrock, ALB, Auto Scaling, IAM, VPC, CloudFormation |
| Automation | Python, Boto3, Bash, Go |

---

## Background

20 years in enterprise networking: Cisco Catalyst/Nexus/ISR, Palo Alto, Firepower, BGP/OSPF, MPLS, ExpressRoute, Azure VNets, IPSec VPN, SIP/VoIP. Now building cloud infrastructure skills on top of that foundation.

More context at [medium.com/@SouthGA_CloudEngineer](https://medium.com/@SouthGA_CloudEngineer).

---

## Upcoming

- Terraform: AWS VPC + Site-to-Site VPN lab with documented routing decisions
- CloudWatch monitoring and alerting tied to existing EC2 workloads
- Python network automation scripts (BGP prefix validation, reachability testing)
- AWS Transit Gateway lab with architecture writeup

---

## Contact

GitHub: [github.com/dkjordan73](https://github.com/dkjordan73)
LinkedIn: [linkedin.com/in/dkjordan](https://www.linkedin.com/in/dkjordan)
Medium: [medium.com/@SouthGA_CloudEngineer](https://medium.com/@SouthGA_CloudEngineer)

