# Level-Up Bank: Highly Available Auto Scaling Web App on AWS

A CloudFormation template that deploys a fault-tolerant web application across three availability zones, fronted by an Application Load Balancer and backed by an Auto Scaling group. The whole environment builds from this one file.

Full write-up: [From Two Servers to Three Under Load: Auto Scaling on AWS](#) (replace with the published article link).

## Architecture

- **VPC** (10.10.0.0/16) with three public subnets, one in each availability zone.
- **Internet gateway** and a public route table for inbound and outbound traffic.
- **Application Load Balancer** spread across all three subnets, health-checking the targets.
- **Auto Scaling group** of t3.micro instances running Apache (min 2, max 5, desired 2), spread across the three AZs.
- **Two security groups**, layered for least privilege:
  - ALB security group: accepts HTTP (80) from the internet.
  - Web server security group: accepts HTTP (80) from the ALB only, nothing from the public.
- Each instance serves a page showing its availability zone and instance ID, which makes the load balancing visible.

## Deploy

```
aws cloudformation deploy \
  --template-file levelup-bank.yaml \
  --stack-name LevelUp-Bank \
  --region us-east-1 \
  --capabilities CAPABILITY_NAMED_IAM
```

Parameters (all have defaults):

- `KeyPairName` — an existing EC2 key pair. Default `Thor_Server`.
- `InstanceType` — default `t3.micro`.
- `AmiId` — resolves the latest Amazon Linux 2023 AMI from SSM by default.

## Verify

Grab the ALB URL from the stack outputs and open it in a browser:

```
aws cloudformation describe-stacks --stack-name LevelUp-Bank --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" --output text
```

Refresh a few times. The instance ID on the page changes, which shows the ALB rotating traffic across instances.

## Test autoscaling

A target tracking CPU policy (about 50% average CPU) drives scaling. To force a scale-out and watch the group grow from 2 to 3:

1. SSH into the running instances (pull the current public IP first; it changes on stop/start).
2. Install and run a stress tool on **both** instances at once, since the policy watches the group average:
   ```
   sudo dnf install -y stress-ng
   stress-ng --cpu 0 --timeout 600s
   ```
3. Watch the CloudWatch alarm flip to In alarm, then the ASG launch a third instance in a third AZ.

To stop instances for the night without the ASG relaunching them, suspend its processes first:

```
aws autoscaling suspend-processes --auto-scaling-group-name LevelUp-ASG
# ...stop instances...
# when returning: start instances, then:
aws autoscaling resume-processes --auto-scaling-group-name LevelUp-ASG
```

## Notes and next steps

- The CPU target tracking policy is created separately from this template. A natural improvement is to define the scaling policy and its alarms as resources here so scaling comes from code too.
- The instances sit in public subnets for direct SSH. A more production-grade setup would use private subnets behind a NAT gateway with SSM Session Manager instead of open SSH.
- Add HTTPS on the load balancer with an ACM certificate.
