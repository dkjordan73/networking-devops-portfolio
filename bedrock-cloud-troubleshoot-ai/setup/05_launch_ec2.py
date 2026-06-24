"""
05_launch_ec2.py
────────────────
Launches an EC2 instance for the Cloud Troubleshooting Assistant
and prints the SSH command and app URL when ready.

Run from your project folder:
    python3 setup/05_launch_ec2.py
"""

import boto3
import time

# ── Config ────────────────────────────────────────────────────────────────────
REGION          = "us-east-1"
KEY_PAIR_NAME   = "Thor_Server"
PEM_FILE_PATH   = "/Users/tinajordan/Desktop/PEM_files/Thor_Server.pem"
SUBNET_ID       = "subnet-05315405d1c2ad318"
INSTANCE_TYPE   = "t3.micro"
INSTANCE_NAME   = "cloud-troubleshoot-assistant"

# Amazon Linux 2023 AMI (us-east-1) — free tier eligible
AMI_ID          = "ami-0fff1b9a61dec8a5f"

# ── Clients ───────────────────────────────────────────────────────────────────
ec2 = boto3.client("ec2", region_name=REGION)


def banner(msg: str):
    print(f"\n{'='*60}\n  {msg}\n{'='*60}")


# ── Step 1: Create Security Group ─────────────────────────────────────────────
def create_security_group() -> str:
    banner("Step 1/3 — Creating Security Group")

    # Get default VPC ID from the subnet
    subnet = ec2.describe_subnets(SubnetIds=[SUBNET_ID])
    vpc_id = subnet["Subnets"][0]["VpcId"]
    print(f"  VPC ID: {vpc_id}")

    # Check if security group already exists
    existing = ec2.describe_security_groups(
        Filters=[
            {"Name": "group-name", "Values": ["cloud-troubleshoot-sg"]},
            {"Name": "vpc-id",     "Values": [vpc_id]},
        ]
    )
    if existing["SecurityGroups"]:
        sg_id = existing["SecurityGroups"][0]["GroupId"]
        print(f"  ℹ️  Security group already exists: {sg_id}")
        return sg_id

    # Create new security group
    sg = ec2.create_security_group(
        GroupName="cloud-troubleshoot-sg",
        Description="Security group for Cloud Troubleshooting Assistant",
        VpcId=vpc_id,
    )
    sg_id = sg["GroupId"]
    print(f"  ✅ Created security group: {sg_id}")

    # Add inbound rules
    ec2.authorize_security_group_ingress(
        GroupId=sg_id,
        IpPermissions=[
            {
                # SSH — port 22
                "IpProtocol": "tcp",
                "FromPort":   22,
                "ToPort":     22,
                "IpRanges":   [{"CidrIp": "0.0.0.0/0", "Description": "SSH access"}],
            },
            {
                # Streamlit — port 8501
                "IpProtocol": "tcp",
                "FromPort":   8501,
                "ToPort":     8501,
                "IpRanges":   [{"CidrIp": "0.0.0.0/0", "Description": "Streamlit app"}],
            },
        ],
    )
    print("  ✅ Inbound rules added: SSH (22) and Streamlit (8501)")
    return sg_id


# ── Step 2: Launch EC2 Instance ───────────────────────────────────────────────
def launch_instance(sg_id: str) -> str:
    banner("Step 2/3 — Launching EC2 Instance")

    # User data script — runs automatically on first boot
    # Installs Python, pip, and project dependencies
    user_data = """#!/bin/bash
yum update -y
yum install -y python3 python3-pip git
pip3 install boto3 streamlit
echo "Bootstrap complete" >> /var/log/bootstrap.log
"""

    response = ec2.run_instances(
        ImageId          = AMI_ID,
        InstanceType     = INSTANCE_TYPE,
        KeyName          = KEY_PAIR_NAME,
        SubnetId         = SUBNET_ID,
        SecurityGroupIds = [sg_id],
        MinCount         = 1,
        MaxCount         = 1,
        UserData         = user_data,
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [
                    {"Key": "Name",    "Value": INSTANCE_NAME},
                    {"Key": "Project", "Value": "cloud-troubleshoot-assistant"},
                ],
            }
        ],
    )

    instance_id = response["Instances"][0]["InstanceId"]
    print(f"  ✅ Instance launched: {instance_id}")
    return instance_id


# ── Step 3: Wait for Instance to be Running ───────────────────────────────────
def wait_for_instance(instance_id: str) -> str:
    banner("Step 3/3 — Waiting for Instance to be Running")
    print("  ⏳ This usually takes 60-90 seconds...")

    while True:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        instance = response["Reservations"][0]["Instances"][0]
        state    = instance["State"]["Name"]
        print(f"     State: {state}")

        if state == "running":
            public_ip = instance.get("PublicIpAddress", "")
            print(f"\n  ✅ Instance is running!")
            print(f"  📍 Public IP: {public_ip}")
            return public_ip

        if state in ("terminated", "shutting-down"):
            raise Exception(f"Instance entered unexpected state: {state}")

        time.sleep(10)


# ── Save instance info ────────────────────────────────────────────────────────
def save_instance_info(instance_id: str, public_ip: str):
    with open("setup/ec2_instance.txt", "w") as f:
        f.write(f"instance_id={instance_id}\n")
        f.write(f"public_ip={public_ip}\n")
    print(f"  💾 Instance info saved to setup/ec2_instance.txt")


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n🚀 Launching EC2 instance for Cloud Troubleshooting Assistant")
    print(f"   Key Pair      : {KEY_PAIR_NAME}")
    print(f"   Instance Type : {INSTANCE_TYPE}")
    print(f"   Subnet        : {SUBNET_ID}")
    print(f"   AMI           : {AMI_ID}")

    sg_id       = create_security_group()
    instance_id = launch_instance(sg_id)
    public_ip   = wait_for_instance(instance_id)

    save_instance_info(instance_id, public_ip)

    print("\n" + "="*60)
    print("✅  EC2 INSTANCE READY")
    print("="*60)
    print(f"\n  Instance ID : {instance_id}")
    print(f"  Public IP   : {public_ip}")
    print(f"\n📋 SSH Command:")
    print(f"   chmod 400 {PEM_FILE_PATH}")
    print(f"   ssh -i {PEM_FILE_PATH} ec2-user@{public_ip}")
    print(f"\n🌐 App URL (after deployment):")
    print(f"   http://{public_ip}:8501")
    print(f"\nNext step: run setup/06_deploy_app.py to copy your project to EC2")
