# WGinDO

Spawns a 512Mb droplet with Debian distr in DigitalOcean and installs WireGuard VPN there.

## Installation

`pip3 install -r requirements.txt`

## Usage

```
$ python3 main.py

__        ______ _       ____   ___  
\ \      / / ___(_)_ __ |  _ \ / _ \ 
 \ \ /\ / / |  _| | '_ \| | | | | | |
  \ V  V /| |_| | | | | | |_| | |_| |
   \_/\_/  \____|_|_| |_|____/ \___/ 

                            by @novitoll                                     

   Spawns a 512Mb droplet with Debian distr in DigitalOcean and installs WireGuard VPN there.

    
[?] Paste a R/W token for DO API: b92cb8d207f6eed7dc1d4fed279836b295985b8ecfd28618ee7d12d6532ec959
[+] Fetching regions
[+] Fetching images
[+] Fetching SSH pub keys
[?] What region do you want to spin a droplet for VPN?: lon1
   nyc1
   sgp1
 > lon1
   nyc3
   ams3
   fra1
   tor1
   sfo2
   blr1

[?] Give a name for your droplet: LON1-wgg
[?] Choose SSH key for root@ user in your droplet: <SSHKey: 26164149 debian-1221>
   <SSHKey: 26164489 AMS>
 > <SSHKey: 26164149 debian-1221>
   NEW_SSH_KEY

[+] Creating droplet
[+] IPv4 is 134.299.299.299
[+] Waiting for droplet is up and then install WireGuard

The authenticity of host '134.299.299.299 (134.299.299.299)' can't be established.
ECDSA key fingerprint is SHA256:2vrXhhxjjEMepAYoT5I3tjY9/RBoA39zjTi8+I62jd4.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '134.299.299.299' (ECDSA) to the list of known hosts.
user-data.sh                                                                                                                                                100% 2903     9.2KB/s   00:00    

[+] STDOUT from user-data.sh

[*] 1. Installing WireGuard..


WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Get:1 http://security.debian.org stretch/updates InRelease [94.3 kB]
Ign:2 http://mirrors.digitalocean.com/debian stretch InRelease
Get:3 http://deb.debian.org/debian unstable InRelease [142 kB]
.......................................................
DKMS: install completed.
Setting up linux-headers-4.9.0-11-amd64 (4.9.189-3+deb9u2) ...
Setting up wireguard (0.0.20191219-1) ...
Setting up linux-headers-amd64 (4.9+80+deb9u9) ...
Processing triggers for libc-bin (2.24-11+deb9u4) ...

[*] 2. Configuring WireGuard interface..


[*] 3. Configuring kernel IP forward..


[*] 4. Starting wg0 interface..

[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.10.0.0/24 dev wg0
[#] ip link set mtu 1420 up dev wg0

[*] 7. Add server's public WG key..


[*] 8. Add /root/add-peer.sh script for RCE...

[Interface]
Address = 10.10.0.2
PrivateKey = QIV96tBze3hoHeApqNNUtOw9gHzPrOkNAc0u/i6aIW4=
DNS = 8.8.8.8, 8.8.4.4, 1.1.1.1
 
[Peer]
PublicKey = 1WoU1N0T2FrlirgrphvxJhfnwDsCfwtZdXG/yVv2JzA=
Endpoint = 134.299.299.299:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
interface: wg0
  public key: 1WoU1N0T2FrlirgrphvxJhfnwDsCfwtZdXG/yVv2JzA=
  private key: (hidden)
  listening port: 51820

peer: nZ1BCXQB/vvJ4hQZxux4UR70RGmngy4IPU0IMJqE42I=
  allowed ips: 10.10.0.2/32
[#] iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
████ ▄▄▄▄▄ █▀█▄▄█ ▄███▀▄█ █▄  █▀▀▀▄▀ ▄▀▀██▀▀▄  ▄▀▄▄ ██ ▄▄▄▄▄ ████
████ █   █ █▀▀▀ █ █▀█▀ ▀▄▀█ ▄ ▀ ▄██▀██▀  █▄▀▄█▄ ▄ ▄ ██ █   █ ████
████ █▄▄▄█ █▀▄ ▀▀▀▄▀ ████▄ █▀█ ▄▄▄  █▀███ ▀▄ ▄▄▄▄█▀▄██ █▄▄▄█ ████
████▄▄▄▄▄▄▄█▄▀▄▀▄▀▄█ ▀ █▄█▄█ ▀ █▄█ ▀ ▀ ▀ █▄█▄█ ▀ ▀ ▀ █▄▄▄▄▄▄▄████
████▄▄   █▄  ▄██ ▄█▀▀▄▄▀▄ █▄▀▄▄ ▄  ▀█ █▀▄██  ██▀  ▀▄▀ █ ▀▄█ ▀████
████▄▀▄▀▀█▄ █▀▀▄▄▀█▀▀▀▀  ▀▀▄ ▀█▀▀██▀▄▀█ ▄▄█▀ ▄▀▀  ▀▄▀▀▀ ▀ ▀▀█████
████ ▄█ ▄█▄  ███ ▀██▄▀  █▄▀▄▀ ▀▄█▄▄▄█▄█▄▄▄█▀█▄▀▄▀▄▄█ ▄█▀▀█▄█▀████
████▄▀▀ ▄▄▄ ▀ █ █▄█ █  ▄  ▀▀████ ▄█▄▀▀ ▄█▄▄▄█▀▀▄█ █ ▄█▄ █   █████
████▄▄▄ ▄ ▄▀▀▄▀▀▀ ███▄ ▀██▀ ▀▀▄   ▀██ ██ ██▀▀▄▀ █▄█▄ █▄▄ █▀▀ ████
████▄ █▀▄█▄ ▀▄ ▀ ▄ ▄     ▀ ▀▀▀▄▄▀███ ▄▄█▀ ▄▀  █▀▀▀▄█ ▀██  ▀▀▀████
██████   ▀▄█▀██▄█▄▄▀█▄▄▄▀▄▀▄▀▄ █▀█ ▄█▄██▄▀▄ █▀  ███  ▀▄ █▀▄ █████
████ ▀▄ █▄▄  ▄▀  █▄▀█▄█▀   █▄█▄█ ▀▀ ▀█▄▀ ▄ ▄██▀ ▀▄█ █▀ ▄▀▄▄▄▀████
████▄ ▄▄▀ ▄  ▄██ ▄▄ ▄ ▄▀▄▀█▀ █▄ ▀▀ █ ▀ █ ██ ██▀▀ ▀█▀▀ ▄▀█▄▄▄█████
████▄ ▄█ ▄▄▄ ▀ █ ▄▀ ██▀██▀███▀ ▄▄▄ ▀▀▀███▄█▄▀█▀▄█ ▄▄ ▄▄▄   ██████
████▄▄▄▄ █▄█ ██ █▄▄███▀ █▄ █▀▀ █▄█  ▀▄▄▄▄██▀▀█ ▄▀███ █▄█ ▀▀▄▀████
████ ▀▀▄▄ ▄▄ ▄█▀ ▀   ▀ █   ▄ █▄▄    ▀▄  ▄▀  █ ▀█▀▄▄▄▄▄  ▄ ▀▄█████
████ ▄▄▄▀▀▄▀ █▀█▀▀▀▄█ ▄▀▄▀▀▄▀██▀▄▄ ██ ▄█▄▄█▀██ ▄▀▀██████▄█▄  ████
████▄ ▄█▀ ▄ ▀▀▀▄█▀█▄   █▀▄█▄▄▄▀ █▀█▀▀▀▄ ██ █▀▄█▄▀▄ █ ▀▀██ ▀ ▀████
████▀█▄█▀▄▄ ███▀███▄▀ ▄▄█ █▄█▄▄▀▄   ██▄█▄▀█▄█  ▄▀ ▄▀  ▄█ █▀▄▄████
████ ▄▄▀  ▄██▄▀  ▀█▄ ▄ █████▀▄▀   ▄▀▀ ▀ ▀▀█▄█ ▀▀▀▀▄▀▄▄█ █▀▄▄▄████
████ ▄▄▀ ▀▄▀▄ ██▀█▀ ▄█▄ ▄▀▀ ▀▀  ▄▄███ █▀▄▄▄▄▄█▄█▀ ▀▀█▀█ ▄ ▄█▀████
████   ▄▄▀▄▄██▄▄▀▄██▀  ▀█▄ ██ ▀█▄▀▄▀  ▀▄▄ ▀▄ ▀█ ▀█▄█▄▄▀▀▀▀▀ ▀████
████▀█▀ █ ▄  ██▄ ▄█ ██ ██▄▀▄▀█▀ ▄█▀▄▀██▄ █▄█▀▄ ██▄█▀▄▀ ██▄█▄ ████
████ ▀ ▀▀▄▄██▄▀▀▀ ██▀█ ████▀██ ▄█▄ ▄▀▀ ██▄▄▀█▀█ ▀▄  ▄▄█  ▀ ▄▀████
██████████▄█ ▀▄▀ ▀ ▄█ ▄▀▄▄▀▄▀█ ▄▄▄ ██ ██ ██▀▀▄ ▀██▄▀ ▄▄▄  ▀██████
████ ▄▄▄▄▄ █▄█ ▄▄▀▄▀██▄▄▄  ▀▀▄ █▄█ ▄  ▄██▄ ▄ █ ▀  ▄▄ █▄█   ▄█████
████ █   █ █ ▄▄█▀▄  █  ▄▀ ▀▄██   ▄▄▄▀█▄█ ▀▄ █▀▀▄█▄█▀ ▄▄   █▄█████
████ █▄▄▄█ █ ██▀ ▀  ██ █▄▀ █▀█▀▄█▄▄▄▀▄▄▀ █ ▄▀██ ▀██▄█ █▀█▄███████
████▄▄▄▄▄▄▄█▄█▄▄█▄▄█▄█▄█▄███▄▄█▄▄▄██████▄██▄██▄██▄▄█▄▄███▄▄▄█████
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████

[+] Done - Scan QR code in your device to connect
[+] Press F? -----> https://www.donationalerts.com/r/novitoll
```
