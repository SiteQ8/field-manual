#!/usr/bin/env bash
# modules/blue/identify.sh

blue_identify() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🔎 BLUE — Identify (Scope)  " \
            --menu "\n  Scanning & Vulnerability Assessment:\n" 20 65 8 \
            "1" "  🗺️   NMAP — Network scanning" \
            "2" "  🔓  Nessus — Vulnerability scanning" \
            "3" "  🟢  OpenVAS — Open source vuln scan" \
            "4" "  🪟  Windows — Network discovery" \
            "5" "  🐧  Linux — Network discovery" \
            "6" "  🔑  Passwords — Brute force & checks" \
            "7" "  🏛️   Active Directory — Enumeration" \
            "8" "  🔢  Hashing — File integrity" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_nmap ;;
            2) _blue_nessus ;;
            3) _blue_openvas ;;
            4) _blue_win_discovery ;;
            5) _blue_linux_discovery ;;
            6) _blue_passwords ;;
            7) _blue_active_directory ;;
            8) _blue_hashing ;;
        esac
    done
}

_blue_nmap() { show_page "NMAP — Network Scanning" \
"═══════════════════════════════════════════════════════════════
  NMAP — Network Scanning                              [BLUE]
═══════════════════════════════════════════════════════════════

  PING SWEEP
    # nmap -sn -PE <IP_RANGE>

  SCAN AND SHOW OPEN PORTS
    # nmap --open <IP_RANGE>

  DETERMINE OPEN SERVICES
    # nmap -sV <IP>

  SCAN HTTP AND HTTPS (80,443)
    # nmap -p 80,443 <IP_RANGE>

  SCAN UDP DNS (port 53)
    # nmap -sU -p 53 <IP_RANGE>

  SCAN UDP + TCP COMBINED (verbose, skip ping)
    # nmap -v -Pn -sU -sT \\
        -p U:53,111,137,T:21-25,80,139,8080 <IP>

  AGGRESSIVE SCAN WITH SCRIPTS
    # nmap -A -T4 <IP_RANGE>

  OS + VERSION DETECTION
    # nmap -O -sV <IP>

  RUN VULNERABILITY SCRIPTS
    # nmap --script=vuln <IP>

  SAVE RESULTS
    # nmap -oN output.txt <IP_RANGE>
    # nmap -oX output.xml <IP_RANGE>
    # nmap -oA all_formats  <IP_RANGE>

  SCAN FROM FILE
    # nmap -iL targets.txt

  FIREWALL EVASION
    # nmap -f <IP>              (fragment packets)
    # nmap -D RND:10 <IP>       (decoy scan)
    # nmap --source-port 53 <IP>
    # nmap --data-length 25 <IP>"; }

_blue_nessus() { show_page "Nessus — Vulnerability Scanning" \
"═══════════════════════════════════════════════════════════════
  Nessus — Vulnerability Scanning                      [BLUE]
═══════════════════════════════════════════════════════════════

  BASIC BATCH SCAN
    # nessus -q -x -T html \\
        <NESSUS_SERVER_IP> 1241 <USER> <PASS> \\
        targets.txt results.html

  REPORT CONVERSION
    # nessus -i in.[nsr|nbe] \\
        -o out.[xml|nsr|nbe|html|txt]

  WEB INTERFACE
    https://localhost:8834
    (Default port 8834)

  API SCAN TRIGGER (curl)
    # curl -k -X POST \\
        'https://<HOST>:8834/scans' \\
        -H 'X-Cookie: token=<TOKEN>' \\
        -d '{\"uuid\":\"<TEMPLATE_UUID>\",
             \"settings\":{\"name\":\"MyScan\",
             \"text_targets\":\"<IP>\"}}'"; }

_blue_openvas() { show_page "OpenVAS — Open Source Vulnerability Scanner" \
"═══════════════════════════════════════════════════════════════
  OpenVAS — Open Source Vulnerability Scanner          [BLUE]
═══════════════════════════════════════════════════════════════

  STEP 1 — Install packages
    # apt-get install openvas-server openvas-client \\
        openvas-plugins-base openvas-plugins-dfsg

  STEP 2 — Update vulnerability database
    # openvas-nvt-sync

  STEP 3 — Add scan user
    # openvas-adduser
    Login:    sysadm
    Auth:     pass
    Password: <YOUR_PASSWORD>
    Rule:     accept <YOUR_IP_RANGE>
              default deny

  STEP 4 — Start the server
    # service openvas-server start

  STEP 5 — Create target list (one host/net per line)
    # vi scanme.txt
    192.168.1.0/24
    10.0.0.1

  STEP 6 — Run scan (text output)
    # openvas-client -q 127.0.0.1 9390 sysadm \\
        nsrc+ws scanme.txt output.txt -T txt -V -x

  STEP 7 — Run scan (HTML output)
    # openvas-client -q 127.0.0.1 9390 sysadm \\
        nsrc+ws scanme.txt output.html -T html -V -x"; }

_blue_win_discovery() { show_page "Windows — Network Discovery" \
"═══════════════════════════════════════════════════════════════
  Windows — Network Discovery                          [BLUE]
═══════════════════════════════════════════════════════════════

  BASIC NETWORK DISCOVERY
    C:\> net view /all
    C:\> net view \\<HOST_NAME>

  PING SWEEP — Write output to file
    C:\> for /L %I in (1,1,254) do ping -w 30 -n 1 \\
         192.168.1.%I | find \"Reply\" >> output.txt

  DHCP — Enable server logging
    C:\> reg add \\
    HKLM\System\CurrentControlSet\Services\DhcpServer\Parameters \\
    /v ActivityLogFlag /t REG_DWORD /d 1

  DNS — Enable logging
    C:\> DNSCmd <SERVER> /config /logLevel 0x8100F331
    C:\> DNSCmd <SERVER> /config /LogFilePath <PATH>
    C:\> DNSCmd <SERVER> /config /logfilemaxsize 0xffffffff

  NETBIOS SCAN
    C:\> nbtstat -A <IP>
    C:\> for /L %I in (1,1,254) do nbtstat -An 192.168.1.%I

  NETDOM — Domain enumeration
    C:\> netdom query WORKSTATION
    C:\> netdom query SERVER
    C:\> netdom query DC
    C:\> netdom query PDC
    C:\> netdom query TRUST
    C:\> netdom query FSMO

  AD COMPUTERS QUERY
    C:\> dsquery COMPUTER \\
         \"OU=servers,DC=<DOMAIN>,DC=<EXT>\" -o rdn

  USER ACTIVITY (PSLoggedOn)
    C:\> psloggedon \\\\computername
    C:\> for /L %i in (1,1,254) do \\
         psloggedon \\\\192.168.1.%i >> users.txt"; }

_blue_linux_discovery() { show_page "Linux — Network Discovery" \
"═══════════════════════════════════════════════════════════════
  Linux — Network Discovery                            [BLUE]
═══════════════════════════════════════════════════════════════

  SMB SCANNING
    # smbtree -b                   (broadcast)
    # smbtree -D                   (domain)
    # smbclient -L <HOST>
    # smbstatus

  PING SWEEP
    # for ip in \$(seq 1 254); do
        ping -c 1 192.168.1.\$ip > /dev/null
        [ \$? -eq 0 ] && echo \"192.168.1.\$ip UP\"
      done

  DHCP LEASE LOGS
    RedHat:  # cat /var/lib/dhcpd/dhcpd.leases
    Ubuntu:  # grep -Ei 'dhcp' /var/log/syslog.1
             # tail -f dhcpd.log

  DNS LOGGING
    # rndc querylog
    # tail -f /var/log/messages | grep named

  NETBIOS SCAN
    # nbtscan <IP_RANGE>

  HASH ALL EXECUTABLES
    # find /<PATH> -type f -exec md5sum {} >> md5sums.txt \\;
    # md5deep -rs / > md5sums.txt

  SMB PASSWORD CHECK LOOP
    # while read u; do
        while read p; do
          smbclient -L <TARGET> -U \$u%\$p -g -d 0
          echo \$u:\$p
        done < passwords.txt
      done < usernames.txt"; }

_blue_passwords() { show_page "Passwords — Brute Force & Checks" \
"═══════════════════════════════════════════════════════════════
  Passwords — Brute Force & Checks                     [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — Single user password loop
    C:\> for /f %i in (passwords.txt) do \\
         @echo %i & net use \\\\<TARGET> %i \\
         /u:<USER> 2>nul && pause

  WINDOWS — User + password combo
    C:\> for /f %i in (users.txt) do \\
         @(for /f %j in (passwords.txt) do \\
         @echo %i:%j & @net use \\\\<TARGET> %j \\
         /u:%i 2>nul && echo %i:%j >> success.txt)

  LINUX — SMB brute force loop
    # while read u; do
        while read p; do
          smbclient -L <TARGET> -U \$u%\$p -g -d 0
          echo \$u:\$p
        done < passwords.txt
      done < users.txt

  HYDRA — SSH
    # hydra -L users.txt -P pass.txt ssh://<IP>

  HYDRA — HTTP POST Form
    # hydra -L users.txt -P pass.txt \\
        http-post-form \"/login:u=^USER^&p=^PASS^:F=error\"

  HYDRA — RDP
    # hydra -L users.txt -P pass.txt rdp://<IP>

  CRACKMAPEXEC — SMB
    # crackmapexec smb <IP> -u users.txt -p pass.txt

  MSBA SCAN
    C:\> mbsacli.exe /target <IP> /n os+iis+sql+password"; }

_blue_active_directory() { show_page "Active Directory — Enumeration" \
"═══════════════════════════════════════════════════════════════
  Active Directory — Enumeration                       [BLUE]
═══════════════════════════════════════════════════════════════

  DOMAIN ENUMERATION (net.exe)
    C:\> net localgroup administrators
    C:\> net localgroup administrators /domain
    C:\> net view /domain
    C:\> net user /domain
    C:\> net user <USERNAME> /domain
    C:\> net accounts /domain

  NETDOM QUERIES
    C:\> netdom query DC
    C:\> netdom query PDC
    C:\> netdom query TRUST
    C:\> netdom query FSMO
    C:\> netdom query WORKSTATION

  DSQUERY — Admin users
    C:\> dsquery * -filter \\
         \"(&(objectclass=user)(admincount=1))\" \\
         -attr samaccountname name

  DSQUERY — Output to file
    C:\> dsquery * -filter \"((objectclass=user))\" \\
         -attr name samaccountname > users.txt

  DSQUERY — Domain trusts
    C:\> dsquery * -filter \\
         \"(objectclass=trusteddomain)\" \\
         -attr flatname trustdirection

  POWERSHELL — AD Users
    PS C:\> Get-ADUser -Filter * | Select Name,Enabled
    PS C:\> Get-ADGroupMember \"Domain Admins\"
    PS C:\> Get-ADDefaultDomainPasswordPolicy

  ADFIND — Users by date
    C:\> adfind -csv -b dc=<DOMAIN>,dc=<EXT> \\
         -f \"(&(objectCategory=Person)
         (whenCreated>=20240101000000.0Z))\""; }

_blue_hashing() { show_page "Hashing — File Integrity Verification" \
"═══════════════════════════════════════════════════════════════
  Hashing — File Integrity Verification                [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — FCIV (File Checksum Integrity Verifier)
    Hash a file:
    C:\> fciv.exe <FILE>

    Hash all files on C:\ into XML database:
    C:\> fciv.exe c:\\ -r -md5 -xml hashes.xml

    List all hashed files:
    C:\> fciv.exe -list -sha1 -xml hashes.xml

    Verify hashes against file system:
    C:\> fciv.exe -v -sha1 -xml hashes.xml

  WINDOWS — PowerShell
    PS C:\> Get-FileHash -Algorithm MD5 <FILE>
    PS C:\> Get-FileHash -Algorithm SHA256 <FILE>
    PS C:\> Get-FileHash -Algorithm SHA512 <FILE>

  WINDOWS — Certutil
    C:\> certutil -hashfile <FILE> SHA1
    C:\> certutil -hashfile <FILE> MD5
    C:\> certutil -hashfile <FILE> SHA256

  LINUX — Hash individual file
    # md5sum <FILE>
    # sha1sum <FILE>
    # sha256sum <FILE>
    # sha512sum <FILE>

  LINUX — Hash all files recursively
    # find /path -type f -exec md5sum {} \\; >> hashes.txt
    # md5deep -rs /path > hashes.txt

  LINUX — Verify against known hashes
    # md5sum -c hashes.txt
    # sha256sum -c hashes.txt"; }
