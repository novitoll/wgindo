#!/bin/bash

set -e

WGPEER_SUBNET="10.10.0.0/24"
WGPEER_IP="${1:-10.10.0.2}"

WGPEER_UDP_PORT="51820"
WGPEER_ENDPOINT="$(hostname -I | awk '{print $1}')"

WGPEER_PUBKEY="/root/wg.pub"
# script for future uses
ADD_PEER_SCRIPT="/root/add-peer.sh"

function RESET() {
	wg-quick down wg0
}

# 1.
echo -e "\n[*] 1. Installing WireGuard..\n"

echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list.d/buster-backports.list

apt update
apt install -y wireguard qrencode

echo "[*] 1.1 Installing Linux kernel 5.9 which has built-in WG.."
apt-get install -y linux-image-5.9.0-4-amd64

# 2.
echo -e "\n[*] 2. Configuring WireGuard interface..\n"

ALLOWED_IPs="0.0.0.0/0"

function set_iptables_chain() {
	local action=$1

	# TODO: Add here ALLOWED_IPs and DROP others before FORWARD

	local forward_in="iptables -$action FORWARD -i %i -j ACCEPT"
	local forward_out="iptables -$action FORWARD -o %i -j ACCEPT"
	local masquerade="iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

	echo "$forward_in; $forward_out; $masquerade"
}

IPTABLES_CHAIN_UP=$(set_iptables_chain A)
IPTABLES_CHAIN_DOWN=$(set_iptables_chain D)

# Save WGPeer privkey
umask 077
wg genkey > /etc/wireguard/privkey
privkey=$(cat /etc/wireguard/privkey)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = $WGPEER_SUBNET
SaveConfig = true
PrivateKey = $privkey
ListenPort = $WGPEER_UDP_PORT
PostUp = $IPTABLES_CHAIN_UP
PostDown = $IPTABLES_CHAIN_DOWN
EOF

# 3.
echo -e "\n[*] 3. Configuring kernel IP forward..\n"
echo 1 > /proc/sys/net/ipv4/ip_forward

verlte() {
	local a=$1
	local b=$2
	[  "$a" = "$(echo -e "$a\n$b" | sort -V | head -n1)" ]
}

verlt() {
	local a=$1
	local b=$2
	[ "$a" = "$b" ] && return 1 || verlte $a $b
}


# 3.1
if verlte $(uname -r) 5.6.0;then
	echo "\n[!] $() Please reboot to boot with >=5.6 Linux kernel.."
	exit 1
fi

# 4.
echo -e "\n[*] 4. Starting wg0 interface..\n"
wg-quick up wg0

# 6. Make server's public key
echo -e "\n[*] 7. Add server's public WG key..\n"
wg pubkey < /etc/wireguard/privkey > ${WGPEER_PUBKEY}

# 7. Write the script for adding peer via RCE providing the assigned subnet
# within wg0 subnet
echo -e "\n[*] 8. Add $ADD_PEER_SCRIPT script for RCE...\n"
cat <<EOF > $ADD_PEER_SCRIPT
#!/bin/bash

ASSIGNED_IPv4_SUBNET="\$1"

if [ -z \$1 ];then
	echo "[-] Please provide IPv4 subnet, e.g. '\$0 10.10.0.2'"
	exit 1
fi

PEER_PRIV="/root/peer-\$ASSIGNED_IPv4_SUBNET.priv"
PEER_PUB="/root/peer-\$ASSIGNED_IPv4_SUBNET.pub"
PEER_CONF="/root/peer-\$ASSIGNED_IPv4_SUBNET.conf"

umask 077
wg genkey > \$PEER_PRIV
wg pubkey < \$PEER_PRIV > \$PEER_PUB

wg set wg0 peer \$(cat \$PEER_PUB) allowed-ips \$ASSIGNED_IPv4_SUBNET

WGPEER_PUB="$(cat $WGPEER_PUBKEY)"

DNS="8.8.8.8, 8.8.4.4, 1.1.1.1"

cat <<_EOF > \$PEER_CONF
[Interface]
Address = \$ASSIGNED_IPv4_SUBNET
PrivateKey = \$(cat \$PEER_PRIV)
DNS = \$DNS
 
[Peer]
PublicKey = \$WGPEER_PUB
Endpoint = $WGPEER_ENDPOINT:$WGPEER_UDP_PORT
AllowedIPs = $ALLOWED_IPs
PersistentKeepalive = 21
_EOF

cat \$PEER_CONF
EOF

chmod +x "$ADD_PEER_SCRIPT"

$ADD_PEER_SCRIPT $WGPEER_IP

# 8. Show wg0
wg

# 9. Print qrencoded peer.conf
qrencode -t ansiutf8 < /root/peer-$WGPEER_IP.conf

echo
echo "[+] Done - Scan QR code in your device to connect"
