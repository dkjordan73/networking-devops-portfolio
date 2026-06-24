"ec2_internet_connectivity.txt": """
EC2 Instance Cannot Reach the Internet - Troubleshooting Guide

SYMPTOMS
- EC2 instance cannot ping 8.8.8.8
- curl/wget commands time out
- Software updates fail (yum update, apt-get update)
- No outbound connectivity from the instance

DIAGNOSTIC STEPS

Step 1: Check the Internet Gateway (IGW)
- Go to VPC Console > Internet Gateways
- Verify an IGW is attached to your VPC
- If no IGW exists, create one and attach it to the VPC
- Command: aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=<vpc-id>

Step 2: Check the Route Table
- Go to VPC Console > Route Tables
- Select the route table associated with the instance's subnet
- Verify there is a route: Destination 0.0.0.0/0 → Target igw-xxxxxxxx
- If missing, add the route: aws ec2 create-route --route-table-id <rtb-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id>

Step 3: Check the Subnet (Public vs Private)
- Confirm the subnet has "Auto-assign public IPv4 address" enabled
- If instance has no public IP, it cannot reach the internet without a NAT Gateway
- For private subnets, route traffic through a NAT Gateway instead of the IGW

Step 4: Check Security Groups (Outbound Rules)
- Go to EC2 Console > Security Groups
- Verify outbound rules allow:
  - TCP port 80 (HTTP) to 0.0.0.0/0
  - TCP port 443 (HTTPS) to 0.0.0.0/0
  - ICMP to 0.0.0.0/0 (for ping)
- Default security groups allow all outbound — check if a custom rule is blocking

Step 5: Check Network ACLs (NACLs)
- NACLs are stateless — both inbound AND outbound rules must allow traffic
- Go to VPC Console > Network ACLs
- Verify outbound rules allow TCP 80/443 to 0.0.0.0/0
- Verify inbound rules allow ephemeral ports 1024-65535 (return traffic)
- NACLs process rules in order by rule number — lower numbers take priority

Step 6: Check the Instance's Elastic IP or Public IP
- If the instance has no public IP and the subnet does not auto-assign one,
  traffic cannot route through the IGW
- Allocate an Elastic IP and associate it with the instance

Step 7: OS-Level Checks (SSH into the instance)
- Check default route: ip route show
- Check if eth0 is up: ip link show eth0
- Test DNS resolution: nslookup google.com
- Check iptables rules: sudo iptables -L -n -v

COMMON ROOT CAUSES
1. Missing 0.0.0.0/0 route to IGW in the route table (most common)
2. Instance deployed in private subnet without NAT Gateway
3. NACL blocking outbound traffic or return traffic
4. Security group outbound rule deleted
5. No public IP assigned to the instance
""",