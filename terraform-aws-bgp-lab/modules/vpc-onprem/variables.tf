variable "vpc_cidr" {
  description = "CIDR block for the on-prem VPC"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access to the CGW instance"
  type        = string
}