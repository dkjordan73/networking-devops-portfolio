variable "vpc_cidr" {
  description = "CIDR block for the cloud VPC"
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