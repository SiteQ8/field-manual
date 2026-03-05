#!/usr/bin/env bash
# modules/blue/os_cheats.sh

blue_os_cheats() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🖥️  BLUE — OS Cheat Sheets  " \
            --menu "\n  Windows & Linux Quick Commands:\n" 18 65 6 \
            "1" "  🪟  Windows — System commands" \
            "2" "  🪟  Windows — PowerShell" \
            "3" "  🐧  Linux — System commands" \
            "4" "  🌐  Networking — Both platforms" \
            "5" "  🔐  Encoding / Decoding" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_win_cmds ;;
            2) _blue_powershell ;;
            3) _blue_linux_cmds ;;
            4) _blue_net_cmds ;;
            5) _blue_encoding ;;
        esac
    done
}

_blue_win_cmds() { show_page "Windows — System Commands" \
"═══════════════════════════════════════════════════════════════
  Windows — System Commands                            [BLUE]
═══════════════════════════════════════════════════════════════

  SYSTEM INFO
    C:\> ver                          OS version
    C:\> systeminfo                   Full system info
    C:\> hostname                     Computer name
    C:\> set                          Environment variables
    C:\> wmic cpu get datawidth       32 or 64 bit
    C:\> wmic qfe list                Installed patches
    C:\> wmic product get name        Installed software

  USERS / GROUPS
    C:\> whoami /all
    C:\> net user
    C:\> net localgroup administrators
    C:\> query user
    C:\> net accounts

  FILE OPERATIONS
    C:\> dir /a /s /b C:\\*pass*       Search for pass files
    C:\> findstr /SI password *.txt   Search file contents
    C:\> type <FILE>                  View file
    C:\> copy, move, del, mkdir, rmdir
    C:\> icacls <FILE>                View permissions
    C:\> takeown /f <FILE>            Take ownership

  PROCESSES / SERVICES
    C:\> tasklist /v
    C:\> taskkill /F /PID <PID>
    C:\> sc query
    C:\> sc start/stop <SERVICE>
    C:\> net start / net stop <SERVICE>

  REGISTRY
    C:\> reg query <KEY>
    C:\> reg add <KEY> /v <VALUE> /t <TYPE> /d <DATA>
    C:\> reg delete <KEY> /v <VALUE>
    C:\> reg export <KEY> backup.reg

  DISK / FILESYSTEM
    C:\> diskpart                     Disk management
    C:\> diskmgmt.msc                 GUI disk manager
    C:\> chkdsk C: /F /R
    C:\> cleanmgr                     Disk cleanup"; }

_blue_powershell() { show_page "Windows — PowerShell" \
"═══════════════════════════════════════════════════════════════
  Windows — PowerShell                                 [BLUE]
═══════════════════════════════════════════════════════════════

  BASICS
    PS C:\> Get-Help <CMDLET> -Examples
    PS C:\> Get-Command *<STRING>*
    PS C:\> Get-Content <FILE>         (cat)
    PS C:\> Set-Content <FILE> <TEXT>
    PS C:\> Get-Process
    PS C:\> Get-Service
    PS C:\> Get-EventLog Security -Newest 50
    PS C:\> Stop-Transcript / Start-Transcript

  FILE HASHING
    PS C:\> Get-FileHash -Algorithm SHA256 <FILE>
    PS C:\> Get-FileHash -Algorithm MD5 <FILE>

  NETWORKING
    PS C:\> Test-NetConnection <HOST> -Port 443
    PS C:\> Resolve-DnsName <HOSTNAME>
    PS C:\> Get-NetIPAddress
    PS C:\> Get-NetTCPConnection | Where State -eq Listen

  DOWNLOAD & EXECUTE
    PS C:\> Invoke-WebRequest -Uri <URL> -OutFile <FILE>
    PS C:\> IEX (New-Object Net.WebClient).DownloadString('<URL>')

  ACTIVE DIRECTORY
    PS C:\> Get-ADUser -Filter *
    PS C:\> Get-ADGroupMember 'Domain Admins'
    PS C:\> Get-ADComputer -Filter * | Select Name,Enabled

  EXECUTION BYPASS
    PS C:\> powershell -ExecutionPolicy Bypass -File <FILE>
    PS C:\> powershell -ep bypass -nop -File <FILE>
    PS C:\> Set-ExecutionPolicy Bypass -Scope Process

  MISC
    PS C:\> \$psVersionTable             PS version
    PS C:\> Get-WmiObject Win32_Product  Installed apps
    PS C:\> Get-ChildItem -Recurse -Force <PATH>"; }

_blue_linux_cmds() { show_page "Linux — System Commands" \
"═══════════════════════════════════════════════════════════════
  Linux — System Commands                              [BLUE]
═══════════════════════════════════════════════════════════════

  SYSTEM INFO
    # uname -a          Kernel + arch
    # cat /etc/os-release
    # hostnamectl
    # uptime
    # df -h             Disk usage
    # free -h           Memory
    # lscpu             CPU info
    # lsblk             Block devices

  USERS / AUTH
    # id                Current user
    # whoami
    # w                 Logged in users
    # last -a           Login history
    # cat /etc/passwd   All users
    # cat /etc/group    All groups
    # sudo -l           Sudo permissions

  PROCESSES
    # ps auxf
    # top / htop
    # kill -9 <PID>
    # pgrep <NAME>
    # pkill <NAME>
    # lsof -p <PID>     Files open by process

  FILES
    # find / -name <FILE> 2>/dev/null
    # find / -perm -4000 -type f   (SUID)
    # grep -rn <PATTERN> /etc/
    # head/tail -n 20 <FILE>
    # wc -l <FILE>
    # diff <FILE1> <FILE2>
    # stat <FILE>       Timestamps + permissions

  PACKAGE MANAGEMENT
    # apt-get update && apt-get upgrade
    # apt-get install <PKG>
    # dpkg -l | grep <PKG>
    # rpm -qa | grep <PKG>          (RedHat)

  ARCHIVE
    # tar -czf out.tar.gz <DIR>
    # tar -xzf file.tar.gz
    # zip -r out.zip <DIR>
    # unzip file.zip"; }

_blue_net_cmds() { show_page "Networking — Both Platforms" \
"═══════════════════════════════════════════════════════════════
  Networking — Both Platforms                          [BLUE]
═══════════════════════════════════════════════════════════════

  INTERFACE INFO
    Linux:   ip a / ifconfig
    Windows: ipconfig /all

  ROUTING TABLE
    Linux:   ip route / route -n
    Windows: route print

  ARP TABLE
    Linux:   arp -a / ip neigh
    Windows: arp -a

  DNS LOOKUP
    Linux:   dig <DOMAIN> / host <DOMAIN>
    Windows: nslookup <DOMAIN>
    Both:    nslookup <DOMAIN> <DNS_SERVER>

  DNS ZONE TRANSFER
    Linux:   dig axfr <DOMAIN> @<NS_IP>
    Windows: nslookup; server <NS>; set type=ANY; ls -d <DOMAIN>

  CONNECTIONS
    Linux:   ss -natp / netstat -natp
    Windows: netstat -naob

  LISTENING PORTS
    Linux:   ss -tlnp
    Windows: netstat -ano | findstr LISTENING

  TRACE ROUTE
    Linux:   traceroute <HOST>
    Windows: tracert <HOST>

  CURL EQUIVALENTS
    Linux:   curl -v <URL>
    Windows: Invoke-WebRequest <URL>
             curl.exe -v <URL>     (Win10+)

  PORT SCAN (quick)
    Linux:   nc -zv <HOST> 1-1024
             nmap -sS <HOST>
    Windows: Test-NetConnection <HOST> -Port <PORT>
             portqry.exe -n <HOST> -e <PORT>"; }

_blue_encoding() { show_page "Encoding & Decoding Reference" \
"═══════════════════════════════════════════════════════════════
  Encoding & Decoding Reference                        [BLUE]
═══════════════════════════════════════════════════════════════

  HEX ENCODING (Linux)
    # echo -n 'text' | xxd -p
    # echo -n 'text' | od -A x -t x1z
    # printf '%s' 'text' | hexdump -v -e '/1 \"%02x\"'

  HEX DECODE (Linux)
    # echo '74657874' | xxd -r -p
    # python3 -c \"print(bytes.fromhex('74657874').decode())\"

  BASE64 ENCODE
    Linux:   echo -n 'text' | base64
    Windows: [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('text'))

  BASE64 DECODE
    Linux:   echo 'dGV4dA==' | base64 -d
    Windows: [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('dGV4dA=='))

  URL ENCODE (Python)
    # python3 -c \"import urllib.parse; print(urllib.parse.quote('text/<>'))\"

  URL DECODE (Python)
    # python3 -c \"import urllib.parse; print(urllib.parse.unquote('text%2F%3C%3E'))\"

  ROT13
    # echo 'text' | tr 'A-Za-z' 'N-ZA-Mn-za-m'

  MD5 / SHA (quick)
    # echo -n 'text' | md5sum
    # echo -n 'text' | sha256sum
    # echo -n 'text' | sha512sum

  CONVERT IP TO HEX
    # python3 -c \"import socket; print(hex(struct.unpack('>I',socket.inet_aton('192.168.1.1'))[0]))\"

  CONVERT HEX TO IP
    # python3 -c \"import socket,struct; print(socket.inet_ntoa(struct.pack('>I',int('0xc0a80101',16))))\""; }
