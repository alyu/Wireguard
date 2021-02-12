output "vpn-server-ip" {
  value       = aws_instance.wireguard-vpn.public_ip
  description = "public vpn server ip"
}
