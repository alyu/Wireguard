Wireguard
=========
This repo creates your own Wireguard VPN server within minutes using Terraform to launch a DigitalOcean droplet or
an Amazon EC2 instance (in an Amazon Virtual Private Cloud with a single public subnet).

Perfect to use if you are a "roadwarrior" and concerned about connecting through insecure networks.

You then install Wireguard on a client such as your laptop and connect to your new VPN server
to proxy and encrypt the traffic through the VPN server.

>WireGuard® is an extremely simple yet fast and modern VPN that utilizes 
>state-of-the-art cryptography. It aims to be faster, simpler, leaner, and more useful than IPsec, while avoiding the massive headache. 
>It intends to be considerably more performant than OpenVPN. 

>WireGuard is designed as a general purpose VPN for running on embedded interfaces and super computers alike, fit for many different circumstances. 

>Initially released for the Linux kernel, it is now cross-platform (Windows, macOS, BSD, iOS, Android) and widely deployable. It is currently under heavy development, but already it might be regarded as the most secure, easiest to use, and simplest VPN solution in the industry.

https://www.wireguard.com

Quickstart (AWS EC2)
==============
You can follow below manual steps or see the [Use the Makefile](#using-the-makefile) section below.
## Prerequisites 
### Install Terraform and Wireguard
Download and follow the installation instructions for your platform:
- [Terraform](https://www.terraform.io/downloads.html)
- [Wireguard](https://www.wireguard.com/install)
- [GNU Make](https://www.gnu.org/software/make)

**Note**: MacOS has a very nice Wireguard UI client that can be installed. 
If you are a command line junky then install wireguard with `port install wireguard-tools`.

### Clone repository
```
$ git clone https://github.com/alyu/wireguard.git
# use AWS EC2
$ cd wireguard/aws
# or digitalocean
# cd wireguard/do
```

## Generate a ssh key for the cloud VPN server
```
$ ssh-keygen -b 2048 -t rsa -f keys/id_rsa -q -N ""; \
    ssh-keygen -lf keys/id_rsa.pub; \
    ssh-keygen -l -E md5 -f keys/id_rsa.pub
```

## Initialize terraform and download plugins
Edit the `terraform.tfvars.template` file and change at minimum:
- access_key &nbsp; &nbsp; &nbsp; &nbsp; # your AWS access key
- secret_key &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;# your AWS secret key
- region &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; # the AWS region to launch into
- instance_type &nbsp; &nbsp; # depending on the region you might for example need to use t3.micro instead of t2.micro

Rename copy the template as `terraform.tfvars`
```
$ cp terraform.tfvars.template terraform.tfvars
```
### Initialize and validate terraform plan
Initialize terraform, download required plugins and validate plan.
```
$ terraform init
$ terraform plan
```
## Launch VPN server and install Wireguard
Take a note of the **Wireguard public server key** and **vpn-server-ip**.
You will need it later when generating the client side Wireguard configuration.

VPN address range: 10.10.100.1/24
```
# Launch cloud infra and install Wireguard
$ terraform apply

# Copy the public server key and vpn server endpoint/ip
...
aws_instance.wireguard-vpn (remote-exec): :: Wireguard server public key: VsUseaRxWWBe3KQoAAXLeU0v9A67qDBk88GJbm1a3z4=
...
vpn-server-ip = 3.112.126.170
```

## Generate client peer Wireguard configuration
### Generate client side peer wireguard keys
```
$ wg genkey | tee keys/client_private_key | wg pubkey > keys/client_public_key
```

### Add the client public key as a peer on the VPN server
```
ssh -i keys/id_rsa <username>@<VPN server ip> "sudo wg set wg0 peer $(cat keys/client_public_key) allowed-ips 10.100.100.2/32
```

## Generate the client peer wireguard config
Set the public server key and the server IP with default udp port 51820.
```
$ ../scripts/install-wireguard.sh -c
:: Client PrivateKey (ANBBdcvAypQJvYs0q398vqWZI6BUkbnnQ/Wkxe0Bmmk=):
:: Client Address (10.100.100.2/32):
:: Server PublicKey (): VsUseaRxWWBe3KQoAAXLeU0v9A67qDBk88GJbm1a3z4=
:: Server Endpoint (<server public ip>:51820): 3.112.126.170:51820
:: Server AllowedIPs (0.0.0.0/0):
:: Created wg0-client.conf ...
:: Do 'wg-quick up ./wg0-client.conf' to activate the VPN.
```

## Activate VPN connection
```
$ wg-quick up ./wg0-client.conf

# Check that your traffic is now being routed through the VPN
# My new public IP should be the VPN server
$ curl ifconfig.me
3.112.126.170

# Take down the VPN connection
$ wg-quick down ./wg0-client.conf
```

Using the Makefile
==================
```
# init terraform
$ make init

# default CLOUD_PROVIDER=aws in the Makefile
# validate terraform plan and create ssh keys if needed
$ make

# launch cloud resources and install the wireguard vpn server
$ make apply

# add the client peer to the vpn server
$ SSH_HOST=root@3.112.126.170 make add-peer

# generate the client wireguard configuration and activate the vpn connection
$ make wg-up

# take down the vpn connection
$ make wg-down
```
## Use DigitalOcean
Edit the `do/terraform.tfvars` file and change at minimum:
- ssh_fingerprint &nbsp; &nbsp; &nbsp; # your digitalocean ssh key fingerprint
- do_token &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;# your digitalocean API token
- region &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; # the AWS region to launch into
- droplet_size &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; # depending on the region you might for example need to use another slug

```
export CLOUD_PROVIDER=do
$ make
$ make apply
...
```
