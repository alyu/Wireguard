# terraform for DO
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_vpc" "wireguard-vpc" {
  name        = var.vpc_name
  region      = var.region
  ip_range    = var.vpc_ip_range
  description = var.vpc_description
}

resource "digitalocean_droplet" "wireguard-vpn" {
  image              = var.droplet_image
  name               = var.droplet_name
  region             = var.region
  vpc_uuid           = digitalocean_vpc.wireguard-vpc.id
  size               = var.droplet_size
  user_data          = file(var.cloud_init_file)
  private_networking = true
  tags               = var.droplet_tags

  ssh_keys           = [
    var.ssh_fingerprint
  ]
 
  connection {
    host        = self.ipv4_address
    user        = var.ssh_username
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/wireguard"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wireguard/install-wireguard.sh",
      "sudo bash -c '/tmp/wireguard/install-wireguard.sh -s'"
    ]
  }
}
