# Cloud Side VPC
resource "aws_vpc" "cloud" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-cloud-vpc"
    Project = var.project_name
    Side    = "cloud"
  }
}

# Public Subnet
resource "aws_subnet" "cloud_public" {
  vpc_id                  = aws_vpc.cloud.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-cloud-public-subnet"
    Project = var.project_name
  }
}

# Private Subnet
resource "aws_subnet" "cloud_private" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "${var.project_name}-cloud-private-subnet"
    Project = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cloud_igw" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    Name    = "${var.project_name}-cloud-igw"
    Project = var.project_name
  }
}

# Virtual Private Gateway
resource "aws_vpn_gateway" "vgw" {
  vpc_id          = aws_vpc.cloud.id
  amazon_side_asn = 64512

  tags = {
    Name    = "${var.project_name}-vgw"
    Project = var.project_name
  }
}

# Public Route Table
resource "aws_route_table" "cloud_public" {
  vpc_id = aws_vpc.cloud.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud_igw.id
  }

  tags = {
    Name    = "${var.project_name}-cloud-public-rt"
    Project = var.project_name
  }
}

# Private Route Table with BGP route propagation enabled
resource "aws_route_table" "cloud_private" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    Name    = "${var.project_name}-cloud-private-rt"
    Project = var.project_name
  }
}

# Enable BGP route propagation from VGW to private route table
resource "aws_vpn_gateway_route_propagation" "cloud_private" {
  route_table_id = aws_route_table.cloud_private.id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

# Route Table Associations
resource "aws_route_table_association" "cloud_public" {
  subnet_id      = aws_subnet.cloud_public.id
  route_table_id = aws_route_table.cloud_public.id
}

resource "aws_route_table_association" "cloud_private" {
  subnet_id      = aws_subnet.cloud_private.id
  route_table_id = aws_route_table.cloud_private.id
}