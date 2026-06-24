"""
06_deploy_app.py
────────────────
Copies the Cloud Troubleshooting Assistant to your EC2 instance
and starts it as a background service.

Run after 05_launch_ec2.py:
    python3 setup/06_deploy_app.py

Requirements:
    - EC2 instance must be running (run 05_launch_ec2.py first)
    - setup/ec2_instance.txt must exist with the public IP
    - Your .pem file must be at the path specified below
"""

import subprocess
import os
import time

# ── Config ────────────────────────────────────────────────────────────────────
PEM_FILE    = "/Users/tinajordan/Desktop/PEM_files/Thor_Server.pem"
EC2_USER    = "ec2-user"
REMOTE_DIR  = "/home/ec2-user/cloud-troubleshoot-assistant"
KB_ID_FILE  = "setup/knowledge_base_id.txt"
INSTANCE_FILE = "setup/ec2_instance.txt"


def banner(msg: str):
    print(f"\n{'='*60}\n  {msg}\n{'='*60}")


def load_public_ip() -> str:
    if not os.path.exists(INSTANCE_FILE):
        raise FileNotFoundError(
            f"Instance file not found: {INSTANCE_FILE}\n"
            "Run 05_launch_ec2.py first."
        )
    with open(INSTANCE_FILE) as f:
        for line in f:
            if line.startswith("public_ip="):
                return line.split("=")[1].strip()
    raise ValueError("public_ip not found in ec2_instance.txt")


def load_kb_id() -> str:
    if not os.path.exists(KB_ID_FILE):
        raise FileNotFoundError(
            f"Knowledge Base ID file not found: {KB_ID_FILE}"
        )
    with open(KB_ID_FILE) as f:
        return f.read().strip()


def run_command(cmd: str, description: str):
    print(f"\n  ▶ {description}")
    result = subprocess.run(
        cmd, shell=True, capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"  ⚠️  Warning: {result.stderr.strip()}")
    else:
        print(f"  ✅ Done")
    return result


def ssh_run(public_ip: str, command: str, description: str):
    ssh_cmd = (
        f'ssh -i {PEM_FILE} '
        f'-o StrictHostKeyChecking=no '
        f'{EC2_USER}@{public_ip} "{command}"'
    )
    return run_command(ssh_cmd, description)


def scp_file(public_ip: str, local_path: str, remote_path: str, description: str):
    scp_cmd = (
        f'scp -i {PEM_FILE} '
        f'-o StrictHostKeyChecking=no '
        f'{local_path} {EC2_USER}@{public_ip}:{remote_path}'
    )
    return run_command(scp_cmd, description)


def scp_directory(public_ip: str, local_path: str, remote_path: str, description: str):
    scp_cmd = (
        f'scp -r -i {PEM_FILE} '
        f'-o StrictHostKeyChecking=no '
        f'{local_path} {EC2_USER}@{public_ip}:{remote_path}'
    )
    return run_command(scp_cmd, description)


if __name__ == "__main__":
    print("\n🚀 Deploying Cloud Troubleshooting Assistant to EC2...")

    public_ip = load_public_ip()
    kb_id     = load_kb_id()

    print(f"   Public IP : {public_ip}")
    print(f"   KB ID     : {kb_id}")
    print(f"   PEM file  : {PEM_FILE}")

    # ── Step 1: Create remote directory structure ──────────────────────────
    banner("Step 1/5 — Creating remote directory structure")
    ssh_run(
        public_ip,
        f"mkdir -p {REMOTE_DIR}/src {REMOTE_DIR}/setup",
        "Creating project folders on EC2"
    )

    # ── Step 2: Copy project files ─────────────────────────────────────────
    banner("Step 2/5 — Copying project files to EC2")
    scp_file(public_ip, "src/app.py",
             f"{REMOTE_DIR}/src/app.py",
             "Copying app.py")

    scp_file(public_ip, "requirements.txt",
             f"{REMOTE_DIR}/requirements.txt",
             "Copying requirements.txt")

    # Copy Knowledge Base ID
    scp_file(public_ip, "setup/knowledge_base_id.txt",
             f"{REMOTE_DIR}/setup/knowledge_base_id.txt",
             "Copying knowledge_base_id.txt")

    # ── Step 3: Configure AWS credentials on EC2 ──────────────────────────
    banner("Step 3/5 — Configuring AWS credentials on EC2")
    print("\n  ⚠️  You need to configure AWS credentials on the EC2 instance.")
    print("  The script will open an SSH session for you to run aws configure.")
    print("  Have your Access Key ID and Secret Access Key ready from your CSV file.")
    print(f"\n  Run this command in a NEW terminal window:")
    print(f"\n  ssh -i {PEM_FILE} {EC2_USER}@{public_ip}")
    print(f"\n  Then run: aws configure")
    print(f"  Region: us-east-1")
    print(f"  Output: json")
    print(f"\n  Once done, come back here and press Enter to continue...")
    input()

    # ── Step 4: Install dependencies on EC2 ───────────────────────────────
    banner("Step 4/5 — Installing Python dependencies on EC2")
    ssh_run(
        public_ip,
        f"cd {REMOTE_DIR} && pip3 install -r requirements.txt",
        "Installing boto3 and streamlit"
    )

    # ── Step 5: Start Streamlit as background process ──────────────────────
    banner("Step 5/5 — Starting Streamlit app")
    ssh_run(
        public_ip,
        (
            f"cd {REMOTE_DIR} && "
            f"nohup streamlit run src/app.py "
            f"--server.port 8501 "
            f"--server.address 0.0.0.0 "
            f"--server.headless true "
            f"> streamlit.log 2>&1 &"
        ),
        "Starting Streamlit in background"
    )

    print("\n  ⏳ Waiting 10 seconds for Streamlit to start...")
    time.sleep(10)

    # Verify it is running
    result = ssh_run(
        public_ip,
        "pgrep -f streamlit && echo 'Streamlit is running' || echo 'Streamlit not found'",
        "Verifying Streamlit is running"
    )

    print("\n" + "="*60)
    print("✅  DEPLOYMENT COMPLETE")
    print("="*60)
    print(f"\n  🌐 Open your app in any browser:")
    print(f"     http://{public_ip}:8501")
    print(f"\n  📋 To check logs on EC2:")
    print(f"     ssh -i {PEM_FILE} {EC2_USER}@{public_ip}")
    print(f"     tail -f /home/ec2-user/cloud-troubleshoot-assistant/streamlit.log")
    print(f"\n  🛑 To stop the app on EC2:")
    print(f"     ssh -i {PEM_FILE} {EC2_USER}@{public_ip}")
    print(f"     pkill -f streamlit")
