#!/usr/bin/env bash
# modules/blue/detect.sh

blue_detect() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  👁️  BLUE — Detect  " \
            --menu "\n  Network & Log Monitoring:\n" 20 65 8 \
            "1" "  📡  TCPDump — Packet capture" \
            "2" "  🦈  TShark — CLI Wireshark" \
            "3" "  🚨  Snort — IDS/IPS rules" \
            "4" "  🪟  Windows — Log auditing" \
            "5" "  🐧  Linux — Log auditing" \
            "6" "  🔒  SSL / TLS checks" \
            "7" "  📊  Auditd — Linux audit daemon" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_tcpdump ;;
            2) _blue_tshark ;;
            3) _blue_snort ;;
            4) _blue_win_logs ;;
            5) _blue_linux_logs ;;
            6) _blue_ssl ;;
            7) _blue_auditd ;;
        esac
    done
}

_blue_tcpdump() { show_page "TCPDump — Packet Capture" \
"═══════════════════════════════════════════════════════════════
  TCPDump — Packet Capture                             [BLUE]
═══════════════════════════════════════════════════════════════

  VIEW TRAFFIC ASCII
    # tcpdump -A

  VIEW TRAFFIC HEX+ASCII
    # tcpdump -X

  VERBOSE WITH TIMESTAMPS
    # tcpdump -tttt -n -vv

  TOP TALKERS (count 1000 packets)
    # tcpdump -nn -c 1000 | \\
      awk '{print \$3}' | cut -d. -f1-4 | \\
      sort | uniq -c | sort -nr

  CAPTURE TO FILE (interface any, dest IP, port 80)
    # tcpdump -w capture.pcap -i any dst <IP> and port 80

  CAPTURE BETWEEN TWO HOSTS
    # tcpdump host 10.0.0.1 && host 10.0.0.2

  CAPTURE FROM HOST (NOT port 22)
    # tcpdump -i eth0 -tttt dst 192.168.1.22 \\
      and not dst port 22

  GRAB CLEAR-TEXT PASSWORDS
    # tcpdump -n -A -s0 \\
      port http or port ftp or port smtp or port imap or \\
      port pop3 or port telnet -lA | \\
      egrep -i -B5 \\
      'pass=|pwd=|log=|login=|user=|username=|password='

  SAVE CAPTURE TO REMOTE HOST
    # tcpdump -w - | ssh <REMOTE_HOST> -p 50005 \\
      \"cat - > /tmp/capture.pcap\"

  DETECT SUSPICIOUS SSL (client hello detect)
    # tcpdump -s 1500 -A \\
      '(tcp[((tcp[12:1] & 0xf0) >> 2)+5:1] = 0x01)'

  READ PCAP FILE
    # tcpdump -r capture.pcap

  DECODE PCAP TO ASCII
    # tcpdump -r capture.pcap -A -n"; }

_blue_tshark() { show_page "TShark — CLI Wireshark" \
"═══════════════════════════════════════════════════════════════
  TShark — CLI Wireshark                               [BLUE]
═══════════════════════════════════════════════════════════════

  LIST INTERFACES
    # tshark -D

  CAPTURE TO FILE
    # tshark -nn -w capture.pcap

  CAPTURE FROM FILE
    # tshark -r capture.pcap

  FILTER DNS QUERIES (show src + query)
    # tshark -n \\
      -e ip.src -e dns.qry.name \\
      -E separator=';' -T fields \\
      port 53

  EXTRACT HTTP HOST + URI
    # tshark -R http.request -T fields \\
      -E separator=';' \\
      -e http.host -e http.request.uri

  TOP TALKERS
    # tshark -n -c 150 | \\
      awk '{print \$4}' | sort | uniq -c | sort -nr

  EXTRACT CREDENTIALS (HTTP)
    # tshark -r capture.pcap -Y 'http.authbasic' \\
      -T fields -e http.authbasic

  SHOW SSL HANDSHAKE
    # tshark -r capture.pcap \\
      -Y 'ssl.handshake.type == 1' \\
      -T fields -e ip.src -e ssl.handshake.extensions_server_name

  FOLLOW TCP STREAM
    # tshark -r capture.pcap \\
      -z follow,tcp,ascii,<STREAM_INDEX>"; }

_blue_snort() { show_page "Snort — IDS / IPS" \
"═══════════════════════════════════════════════════════════════
  Snort — Intrusion Detection System                   [BLUE]
═══════════════════════════════════════════════════════════════

  TEST CONFIGURATION
    # snort -T -c /etc/snort/snort.conf

  RUN ON SAVED LOG FILE
    # snort -dv -r logfile.log

  CONSOLE OUTPUT MODE
    # snort -q -A console -i eth0 \\
      -c /etc/snort/snort.conf

  DAEMON MODE
    # snort -D -i eth0 \\
      -c /etc/snort/snort.conf \\
      -l /var/log/snort

  SNORT RULE SYNTAX
    ────────────────────────────────────────────────────
    action proto src_ip src_port dir dst_ip dst_port (options)
    ────────────────────────────────────────────────────

  RULE EXAMPLES
    # alert TCP scan
    alert tcp any any -> any any \\
      (msg:\"TCP\"; flags:S; threshold: type both, \\
      track by_src, count 100, seconds 10; \\
      sid:1000001; rev:1;)

    # alert Nmap scan
    alert tcp any any -> any any \\
      (msg:\"NMAP NULL Scan\"; flags:0; \\
      sid:1000002; rev:1;)

    # alert HTTP
    alert tcp any any -> any 80 \\
      (msg:\"HTTP Traffic\"; sid:9001; rev:1;)

  RULE ACTIONS
    alert  — generate alert + log
    log    — log packet
    pass   — ignore packet
    drop   — block + log (IPS mode)
    reject — block + send reset
    sdrop  — block silently"; }

_blue_win_logs() { show_page "Windows — Log Auditing" \
"═══════════════════════════════════════════════════════════════
  Windows — Log Auditing                               [BLUE]
═══════════════════════════════════════════════════════════════

  AUDIT POLICY — Check current
    C:\> auditpol /get /category:*

  AUDIT POLICY — Enable all events
    C:\> auditpol /set /category:* \\
         /success:enable /failure:enable

  AUDIT POLICY — Logon events only
    C:\> auditpol /set \\
         /subcategory:\"Logon\" \\
         /success:enable /failure:enable

  AUDIT POLICY — Process creation
    C:\> auditpol /set \\
         /subcategory:\"Process Creation\" \\
         /success:enable /failure:enable

  INCREASE SECURITY LOG SIZE (100MB)
    C:\> reg add \\
    HKLM\\Software\\Policies\\Microsoft\\Windows\\Eventlog\\Security \\
    /v MaxSize /t REG_DWORD /d 0x64000

  CHECK LOG SIZE
    C:\> wevtutil gl Security

  QUERY LAST 100 LOGONS (Event 4624)
    C:\> wevtutil qe security \\
         /q:\"*[System[(EventID=4624)]]\" \\
         /c:100 /rd:true /f:text

  QUERY FAILED LOGONS (Event 4625)
    C:\> wevtutil qe Security \\
         /q:\"*[System[(EventID=4625)]]\" \\
         /f:text

  EXPORT LOG FILE
    C:\> wevtutil epl Security security.evtx

  POWERSHELL — Get logon events
    PS C:\> Get-Eventlog Security | \\
            ? { \$_.Eventid -eq 4624 }

  POWERSHELL — Last 14 days auth events
    PS C:\> Get-Eventlog Security \\
            4768,4771,4772,4769,4770,4778,4779,4800,4801 \\
            -after ((get-date).addDays(-14))

  POWERSHELL — Remote event log
    PS C:\> Get-EventLog -ComputerName <HOST> -LogName Security

  REMOTE LOGS
    C:\> Show-Eventlog -computername <SERVER>"; }

_blue_linux_logs() { show_page "Linux — Log Auditing" \
"═══════════════════════════════════════════════════════════════
  Linux — Log Auditing                                 [BLUE]
═══════════════════════════════════════════════════════════════

  KEY LOG FILES
    /var/log/syslog         — System messages
    /var/log/auth.log       — Authentication attempts
    /var/log/kern.log       — Kernel messages
    /var/log/messages       — General messages
    /var/log/secure         — RedHat auth log
    /var/log/btmp           — Failed logins (use lastb)
    /var/log/wtmp           — Login history (use last)
    /var/log/lastlog        — Last login per user
    ~/.bash_history         — Command history
    /var/log/apache2/       — Web server logs
    /var/log/nginx/         — Nginx logs

  VIEW FAILED SSH LOGINS
    # grep \"Failed password\" /var/log/auth.log | tail -20

  VIEW SUCCESSFUL SSH LOGINS
    # grep \"Accepted password\\|Accepted publickey\" \\
      /var/log/auth.log

  WATCH AUTH LOG LIVE
    # tail -f /var/log/auth.log

  LAST LOGIN INFO
    # last -a | head -20
    # lastb -a | head -20    (bad logins)
    # lastlog                 (all users last login)

  CHECK FOR SUSPICIOUS CRONS
    # crontab -l
    # cat /etc/crontab
    # ls /etc/cron.*

  FIND MODIFIED FILES (last 24h)
    # find /etc -mtime -1 -type f
    # find /bin /sbin /usr -mtime -7 -type f

  CHECK SUDOERS
    # cat /etc/sudoers
    # grep -v '#' /etc/sudoers | grep -v '^\$'

  LARGE FILES (possible exfil staging)
    # find / -size +500M -type f 2>/dev/null"; }

_blue_ssl() { show_page "SSL / TLS Certificate Checks" \
"═══════════════════════════════════════════════════════════════
  SSL / TLS Certificate Checks                         [BLUE]
═══════════════════════════════════════════════════════════════

  RETRIEVE SERVER CERTIFICATE
    # openssl s_client -connect <HOST>:443 </dev/null \\
      2>/dev/null | \\
      sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \\
      > cert.pem

  EXAMINE CERTIFICATE
    # openssl x509 -text -in cert.pem

  VERIFY CERTIFICATE CHAIN
    # openssl verify cert.pem

  CHECK EXPIRY DATE
    # echo | openssl s_client -connect <HOST>:443 \\
      2>/dev/null | openssl x509 -noout -dates

  GET FULL CHAIN
    # openssl s_client -showcerts \\
      -connect <HOST>:443 </dev/null

  CHECK SUPPORTED CIPHERS (nmap)
    # nmap --script ssl-enum-ciphers -p 443 <HOST>

  CHECK FOR HEARTBLEED (CVE-2014-0160)
    # nmap -sV --script=ssl-heartbleed <HOST>

  CHECK TLS VERSION
    # nmap --script ssl-dh-params -p 443 <HOST>

  TESTSSL.SH (comprehensive)
    # testssl.sh https://<HOST>
    # testssl.sh --vulnerable <HOST>:443

  SSLSCAN
    # sslscan --show-certificate <HOST>:443"; }

_blue_auditd() { show_page "Auditd — Linux Audit Daemon" \
"═══════════════════════════════════════════════════════════════
  Auditd — Linux Audit Daemon                          [BLUE]
═══════════════════════════════════════════════════════════════

  START / STATUS
    # service auditd start
    # auditctl -s

  WATCH KEY FILES
    # auditctl -w /etc/passwd -p wa -k passwd_changes
    # auditctl -w /etc/sudoers -p wa -k sudoers
    # auditctl -w /etc/shadow -p wa -k shadow
    # auditctl -w /bin/su -p x -k su_exec

  WATCH DIRECTORY FOR EXEC
    # auditctl -w /tmp -p x -k tmp_exec

  WATCH SYSCALL (e.g. all open by root)
    # auditctl -a always,exit -F arch=b64 \\
      -S open -F uid=0 -k root_opens

  SEARCH AUDIT LOG
    # ausearch -k passwd_changes
    # ausearch -k passwd_changes --start today
    # ausearch -f /etc/passwd
    # ausearch -m LOGIN --start today --end now

  REPORTS
    # aureport -au              (authentication)
    # aureport -x               (executable)
    # aureport --failed          (failed events)
    # aureport --summary         (summary)

  LIST CURRENT RULES
    # auditctl -l

  DELETE ALL RULES
    # auditctl -D

  MAKE RULES PERSISTENT
    # vi /etc/audit/audit.rules
    (Add -w and -a lines, then service auditd restart)"; }
