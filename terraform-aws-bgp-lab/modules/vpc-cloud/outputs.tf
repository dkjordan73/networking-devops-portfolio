output "vpc_id" {
  description = "Cloud VPC ID"
  value       = aws_vpc.cloud.id
}

output "public_subnet_id" {
  description = "Cloud public subnet ID"
  value       = aws_subnet.cloud_public.id
}

output "private_subnet_id" {
  description = "Cloud private subnet ID"
  value       = aws_subnet.cloud_private.id
}

output "vgw_id" {
  description = "Virtual Private Gateway ID"
  value       = aws_vpn_gateway.vgw.id
}