output "vpc_id" {
  description = "On-prem VPC ID"
  value       = aws_vpc.onprem.id
}

output "public_subnet_id" {
  description = "On-prem public subnet ID"
  value       = aws_subnet.onprem_public.id
}

output "cgw_sg_id" {
  description = "Security group ID for the CGW instance"
  value       = aws_security_group.onprem_cgw.id
}