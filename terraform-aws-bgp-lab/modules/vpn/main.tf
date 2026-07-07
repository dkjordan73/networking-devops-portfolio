# Customer Gateway - represents the on-prem side
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.cgw_public_ip
  type       = "ipsec.1"

  tags = {
    Name    = "${var.project_name}-cgw"
    Project = var.project_name
  }
}

# Site-to-Site VPN Connection
resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  vpn_gateway_id      = var.vgw_id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name    = "${var.project_name}-vpn-connection"
    Project = var.project_name
  }
}
