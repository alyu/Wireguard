variable "do_token" {
  type        = string
  description = "digitalocean token"
}

variable "pub_key" {
  type        = string
  description = "public key file path"
}

variable "pvt_key" {
  type        = string
  description = "private key file path"
}

variable "ssh_fingerprint" {
  type        = string
  description = "digitalocean ssh key fingerprint"
}

variable "ssh_username" {
  type        = string
  description = "ssh os user name"
}

variable "vpc_name" {
  type        = string
  description = "digitalocean vpn name"
}

variable "vpc_ip_range" {
  type        = string
  description = "digitalocean vpc ip range"
}

variable "vpc_description" {
  type        = string
  description = "digitalocean vpc description"
}

variable "region" {
  type        = string
  description = "digitalocean region"
}

variable "cloud_init_file" {
  type        = string
  description = "cloud init filename"
}

variable "droplet_image" {
  type        = string
  description = "droplet image"
}

variable "droplet_name" {
  type        = string
  description = "droplet name"
}

variable "droplet_size" {
  type        = string
  description = "droplet size"
}

variable "droplet_tags" {
  type        = list(string)
  description = "droplet tag1"
}
