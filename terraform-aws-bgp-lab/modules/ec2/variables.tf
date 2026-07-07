variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "public_key_path" {
  description = "Path to your local SSH public key"
  type        = string
}

variable "cloud_vpc_id" {
  description = "Cloud VPC ID from vpc-cloud module"
  type        = string
}

variable "cloud_private_subnet_id" {
  description = "Cloud private subnet ID from vpc-cloud module"
  type        = string
}

variable "onprem_public_subnet_id" {
  description = "On-prem public subnet ID from vpc-onprem module"
  type        = string
}

variable "onprem_cgw_sg_id" {
  description = "Security group ID for the CGW instance from vpc-onprem module"
  type        = string
}
