output "onprem_cgw_public_ip" {
  description = "Public IP of the StrongSwan/FRRouting CGW instance"
  value       = aws_instance.onprem_cgw.public_ip
}

output "cloud_test_instance_private_ip" {
  description = "Private IP of the cloud side test instance"
  value       = aws_instance.cloud_test.private_ip
}