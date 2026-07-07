variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource tagging and naming"
  type        = string
  default     = "terraform-aws-bgp-lab"
}

variable "cloud_vpc_cidr" {
  description = "CIDR block for the cloud-side VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "onprem_vpc_cidr" {
  description = "CIDR block for the simulated on-prem VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "my_ip" {
  description = "Your public IP address for SSH access"
  type        = string
}

variable "public_key_path" {
  description = "Path to your SSH public key on your local machine"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}