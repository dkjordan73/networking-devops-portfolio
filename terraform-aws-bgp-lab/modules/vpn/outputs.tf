output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = aws_vpn_connection.main.id
}

output "tunnel1_address" {
  description = "Outside IP of VPN tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "tunnel2_address" {
  description = "Outside IP of VPN tunnel 2"
  value       = aws_vpn_connection.main.tunnel2_address
}

output "tunnel1_cgw_inside_address" {
  description = "Inside IP for CGW side of tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_cgw_inside_address
}

output "tunnel1_vgw_inside_address" {
  description = "Inside IP for VGW side of tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_vgw_inside_address
}

output "tunnel1_bgp_asn" {
  description = "BGP ASN for tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_bgp_asn
}

output "tunnel1_preshared_key" {
  description = "Pre-shared key for tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive   = true
}