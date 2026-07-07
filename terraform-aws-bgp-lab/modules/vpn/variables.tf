variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "vgw_id" {
  description = "Virtual Private Gateway ID from the cloud VPC module"
  type        = string
}

variable "cgw_public_ip" {
  description = "Public IP of the EC2 instance running StrongSwan on the on-prem side"
  type        = string
}