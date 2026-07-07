output "onprem_cgw_public_ip" {
  description = "Public IP of the StrongSwan/FRRouting instance"
  value       = module.ec2.onprem_cgw_public_ip
}

output "cloud_test_instance_private_ip" {
  description = "Private IP of the cloud side test instance"
  value       = module.ec2.cloud_test_instance_private_ip
}

output "vpn_tunnel1_address" {
  description = "AWS side outside IP for tunnel 1"
  value       = module.vpn.tunnel1_address
}

output "vpn_tunnel2_address" {
  description = "AWS side outside IP for tunnel 2"
  value       = module.vpn.tunnel2_address
}

output "tunnel1_cgw_inside_address" {
  description = "Inside IP for CGW side of tunnel 1"
  value       = module.vpn.tunnel1_cgw_inside_address
}

output "tunnel1_vgw_inside_address" {
  description = "Inside IP for VGW side of tunnel 1"
  value       = module.vpn.tunnel1_vgw_inside_address
}

output "tunnel1_preshared_key" {
  description = "Pre-shared key for tunnel 1"
  value       = module.vpn.tunnel1_preshared_key
  sensitive   = true
}