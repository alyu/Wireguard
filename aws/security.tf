resource "aws_security_group_rule" "Wireguard-VPC-ssh" {
  security_group_id = module.vpc.default_security_group_id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "Wireguard-VPC-wireguard" {
  security_group_id = module.vpc.default_security_group_id

  type        = "ingress"
  from_port   = 51820
  to_port     = 51820 
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}
