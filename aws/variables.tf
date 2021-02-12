variable "access_key" {
  type        = string
  description = "aws access key"
}

variable "secret_key" {
  type        = string
  description = "aws secret key"
}

variable "keypair_name" {
  type        = string
  description = "aws keypair name"
}

variable "pub_key" {
  type        = string
  description = "public ssh key file path"
}

variable "pvt_key" {
  type        = string
  description = "private ssh key file path"
}

variable "ssh_username" {
  type        = string
  description = "SSH OS user name"
}

variable "region" {
  type        = string
  description = "aws region"
}

variable "image_vendor" {
  type        = string
  description = "image vendor"
  default     = "ubuntu"
}

variable "image_name" {
  type        = list(string)
  description = "image name"
  default     = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
}

variable "image_virtualization_type" {
  type        = list(string)
  description = "image virtualization type"
  default     = ["hvm"]
}

variable "image_owners" {
  type        = list(string)
  description = "image owners"
  default     = ["099720109477"] # Canonical
}

variable "instance_type" {
  type        = string
  description = "aws instance type"
  default     = "t2.micro"
}

variable "instance_private_ip" {
  type        = string
  description = "instance private ip"
  default     = "10.10.10.10"
}

variable "instance_volume_type" {
  type        = string
  description = "instance volume type"
  default     = "gp2"
}

variable "instance_volume_size" {
  type        = number
  description = "instance volume size"
  default     = 8
}

variable "vpc_name" {
  type        = string
  description = "vpc name"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
  default     = "10.10.0.0/16"
}

variable "vpc_azs" {
  type        = string
  description = "vpc availability zone"
  default     = "ap-northeast-1b"
}

variable "vpc_public_subnet" {
  type        = string
  description = "vpc public subnet"
  default     = "10.10.10.0/24"
}

variable "vpc_public_subnet_name" {
  type        = string
  description = "vpc public subnet name"
  default     = "Public subnet"
}

variable "vpc_private_subnet" {
  type        = string
  description = "vpc private subnet"
  default     = "10.10.20.0/24"
}

variable "vpc_private_subnet_name" {
  type        = string
  description = "vpc private subnet name"
  default     = "Privaate subnet"
}

variable "cloud_init_file" {
  type        = string
  description = "cloud init filename"
}

variable "tag1" {
  type        = string
  description = "tag1"
}

variable "tag2" {
  type        = string
  description = "tag2"
}

variable "tag3" {
  type        = string
  description = "tag3"
}
