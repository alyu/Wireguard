output "vpn-server-ip" {
  value = digitalocean_droplet.wireguard-vpn.ipv4_address
  description = "public vpn server ip"
}
