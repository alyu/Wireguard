#!/usr/bin/env bash

ask() {
  read -p "$1" x
  [[ -z "$x" ]] || [[ "$x" == ["$2${2^^}"] ]] && return 0

  return 1
}

installWireGuard() {
  apt update && apt upgrade -y && apt install -y wireguard wireguard-tools
}

installServer() {
  installWireGuard

  mkdir -p /etc/wireguard/keys && cd /etc/wireguard/keys
  umask 077
  wg genkey | tee server_private_key | wg pubkey > server_public_key
  local server_private_key=$(cat server_private_key)
  local server_public_key=$(cat server_public_key)
  local upd_port=${1-51820}
  local server_cidr=${2-"10.100.100.1/24"}
  # FIXME how reliable is this
  local interface="$(ip route get 1 | head -1 | cut -d' ' -f5)"

  cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address     = ${server_cidr}
PrivateKey  = ${server_private_key}
ListenPort  = ${upd_port}
PostUp      = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${interface} -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ${interface} -j MASQUERADE; iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT; iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
PostDown    = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${interface} -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ${interface} -j MASQUERADE
SaveConfig  = true
EOF
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/60-ip_forward
  sysctl -p
  echo 1 > /proc/sys/net/ipv4/ip_forward

  chown -v root:root /etc/wireguard/wg0.conf
  chmod -v 600 /etc/wireguard/wg0.conf
  wg-quick up wg0
  systemctl enable wg-quick@wg0.service

  echo ":: Wireguard server public key: ${server_public_key}"
}

addClientPeer() {
  local allowed_ips=${1-"10.100.100.2/32"}
  mkdir keys && cd keys
  wg genkey | tee client_private_key | wg pubkey > client_public_key
  local client_private_key=$(cat client_private_key)
  local client_public_key=$(cat client_public_key)
  read -p ":: Enter client public key (${client_public_key}): " x
  [[ -z ${x} ]] || client_public_key=${x}

  read -p ":: Enter allowed IPs (${allowed_ips}): " x
  [[ -z ${x} ]] || allowed_ips=${x}

  wg set wg0 peer ${client_public_key} allowed-ips ${allowed_ips}
  wg-quick save wg0
}

createClientConfig() {
  command -v wg &>/dev/null || installWireGuard 
  local client_private_key="$(cat keys/client_private_key 2>/dev/null)"
  local client_cidr="10.100.100.2/24"
  local server_public_key="$(cat keys/server_public_key 2>/dev/null)"
  local server_endpoint="<server public ip>:51820"
  local allowed_ips="0.0.0.0/0"
  local wgconfig="${PWD}/wg0-client.conf"

  [[ -f ${wgconfig} ]] && ask ":: Overwrite ${wgconfig}? (y/N): " "n" && exit 0

  read -p ":: Client PrivateKey (${client_private_key}): " x
  [[ -z ${x} ]] || client_private_key=${x}

  read -p ":: Client Address (${client_cidr}): " x
  [[ -z ${x} ]] || client_cidr=${x}

  read -p ":: Server PublicKey (${server_public_key}): " x
  [[ -z ${x} ]] || server_public_key=${x}

  read -p ":: Server Endpoint (${server_endpoint}): " x
  [[ -z ${x} ]] || server_endpoint=${x}

  read -p ":: Server AllowedIPs (${allowed_ips}): " x
  [[ -z ${x} ]] || allowed_ips=${x}

  umask 077
  cat > ${wgconfig} << EOF
[Interface]
PrivateKey = ${client_private_key}
Address = ${client_cidr}
DNS = 1.1.1.1

[Peer]
PublicKey = ${server_public_key}
Endpoint = ${server_endpoint}
AllowedIPs = ${allowed_ips}
PersistentkeepAlive = 60
EOF

  echo ":: Created ${wgconfig} ..."
  echo ":: Do 'wg-quick up ${wgconfig}' to activate the VPN."
}

PARAMS=""
while (( "$#" > 0 )); do
  case "$1" in
    -s|--server-private-key)
      installServer
      shift
      ;;
    -a|--add-peer)
      addClientPeer
      shift
      ;;
    -c|--create-config)
      createClientConfig
      shift
      ;;
    --)
      shift
      break
      ;;
    -*|--*=)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# preseve whitespace for the args e.g., "ab dc"
eval set -- "$PARAMS"

exit 0
