# On-Prem Simulated VPC
resource "aws_vpc" "onprem" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-onprem-vpc"
    Project = var.project_name
    Side    = "onprem"
  }
}

# Public Subnet
resource "aws_subnet" "onprem_public" {
  vpc_id                  = aws_vpc.onprem.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-onprem-public-subnet"
    Project = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "onprem_igw" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name    = "${var.project_name}-onprem-igw"
    Project = var.project_name
  }
}

# Route Table
resource "aws_route_table" "onprem_public" {
  vpc_id = aws_vpc.onprem.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.onprem_igw.id
  }

  tags = {
    Name    = "${var.project_name}-onprem-public-rt"
    Project = var.project_name
  }
}

# Route Table Association
resource "aws_route_table_association" "onprem_public" {
  subnet_id      = aws_subnet.onprem_public.id
  route_table_id = aws_route_table.onprem_public.id
}

# Security Group for StrongSwan/FRRouting EC2
resource "aws_security_group" "onprem_cgw" {
  name        = "${var.project_name}-onprem-cgw-sg"
  description = "Allow IKE, IPSec, and BGP traffic for simulated CGW"
  vpc_id      = aws_vpc.onprem.id

  # IKE negotiation
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IKE"
  }

  # IPSec NAT traversal
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IPSec NAT-T"
  }

  # BGP
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "BGP"
  }

  # SSH for management
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
    Name    = "${var.project_name}-onprem-cgw-sg"
    Project = var.project_name
  }
}