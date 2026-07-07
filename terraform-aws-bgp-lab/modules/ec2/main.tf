# AMI lookup - latest Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair for SSH access
resource "aws_key_pair" "lab" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

# Security Group for cloud side test instance
resource "aws_security_group" "cloud_test" {
  name        = "${var.project_name}-cloud-test-sg"
  description = "Allow ICMP and SSH for reachability testing"
  vpc_id      = var.cloud_vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "ICMP from RFC1918"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "SSH management"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name    = "${var.project_name}-cloud-test-sg"
    Project = var.project_name
  }
}

# Cloud side test EC2 instance
resource "aws_instance" "cloud_test" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.cloud_private_subnet_id
  vpc_security_group_ids = [aws_security_group.cloud_test.id]
  key_name               = aws_key_pair.lab.key_name

  tags = {
    Name    = "${var.project_name}-cloud-test-instance"
    Project = var.project_name
    Side    = "cloud"
  }
}

# On-prem side CGW EC2 instance running StrongSwan and FRRouting
resource "aws_instance" "onprem_cgw" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.onprem_public_subnet_id
  vpc_security_group_ids      = [var.onprem_cgw_sg_id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  # Required for the instance to forward packets between tunnel and VPC
  source_dest_check = false

user_data = <<-EOF
#!/bin/bash
apt-get update -y
apt-get install -y strongswan frr frr-pythontools
systemctl enable strongswan
systemctl enable frr
EOF

  tags = {
    Name    = "${var.project_name}-onprem-cgw-instance"
    Project = var.project_name
    Side    = "onprem"
  }
}