data "aws_ami" "instance" {
  most_recent = true

  filter {
    name   = "name"
    values = var.image_name
  }

  filter {
    name   = "virtualization-type"
    values = var.image_virtualization_type
  }

  owners = var.image_owners
}

resource "aws_key_pair" "default" {
  key_name   = var.keypair_name
  public_key = file(var.pub_key)
}

resource "aws_instance" "wireguard-vpn" {
  ami                         = data.aws_ami.instance.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.default.id
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  private_ip                  = var.instance_private_ip
  user_data                   = file(var.cloud_init_file)
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_type = var.instance_volume_type
    volume_size = var.instance_volume_size
  }

  tags = {
    Name = var.tag1
    Terraform = "true"
    Environment = var.tag2
  }

  connection {
    user        = var.ssh_username
    private_key = file(var.pvt_key)
    host        = aws_instance.wireguard-vpn.public_ip
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/wireguard/"
  }

  # install and setup wireguard
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting to boot up ...' && sleep 20",
      "chmod +x /tmp/wireguard/install-wireguard.sh",
      "sudo bash -c '/tmp/wireguard/install-wireguard.sh -s'"
    ]
  }
}
