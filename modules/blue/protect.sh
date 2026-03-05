#!/usr/bin/env bash
# modules/blue/protect.sh

blue_protect() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🛡️  BLUE — Protect (Defend)  " \
            --menu "\n  Hardening & Protection Controls:\n" 20 65 8 \
            "1" "  🔥  IPTables — Linux firewall" \
            "2" "  🔒  UFW — Uncomplicated firewall" \
            "3" "  🪟  Windows Firewall — netsh" \
            "4" "  🔑  Password Hardening" \
            "5" "  📋  AppLocker — Application control" \
            "6" "  🔐  IPSEC Configuration" \
            "7" "  🗂️   Registry Hardening — Windows" \
            "8" "  🍯  Honeypot Techniques" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_iptables ;;
            2) _blue_ufw ;;
            3) _blue_winfw ;;
            4) _blue_passwd_harden ;;
            5) _blue_applocker ;;
            6) _blue_ipsec ;;
            7) _blue_reg_harden ;;
            8) _blue_honeypot ;;
        esac
    done
}

_blue_iptables() { show_page "IPTables — Linux Firewall" \
"═══════════════════════════════════════════════════════════════
  IPTables — Linux Firewall                            [BLUE]
═══════════════════════════════════════════════════════════════

  EXPORT / IMPORT RULES
    # iptables-save > firewall.out
    # vi firewall.out
    # iptables-restore < firewall.out

  BLOCK SINGLE IP / SUBNET
    # iptables -A INPUT -s 10.10.10.10 -j DROP
    # iptables -A INPUT -s 10.10.10.0/24 -j DROP

  BLOCK PORT FROM IP
    # iptables -A INPUT -p tcp -s 10.10.10.10 \\
        --dport 22 -j DROP

  LOCKDOWN (block all)
    # iptables -P INPUT DROP
    # iptables -P OUTPUT DROP
    # iptables -P FORWARD DROP

  LOG DENIED PACKETS
    # iptables -I INPUT 5 -m limit --limit 5/min \\
        -j LOG --log-prefix \"iptables denied: \" --log-level 7

  SAVE PERSISTENTLY
    # /etc/init.d/iptables save
    # /sbin/service iptables save
    # iptables-save > /etc/iptables/rules.v4

  LIST / FLUSH
    # iptables -L -v -n --line-numbers
    # iptables -F

  START / STOP
    # service iptables start
    # service iptables stop

  ALLOW IPSEC TRAFFIC
    # iptables -A INPUT -p esp -j ACCEPT
    # iptables -A INPUT -p ah -j ACCEPT
    # iptables -A INPUT -p udp --dport 500 -j ACCEPT
    # iptables -A INPUT -p udp --dport 4500 -j ACCEPT

  PORT FORWARD
    # echo 1 > /proc/sys/net/ipv4/ip_forward
    # iptables -t nat -A PREROUTING -p tcp \\
        --dport 3389 -j DNAT --to 192.168.1.2:3389
    # iptables -t nat -A POSTROUTING -j MASQUERADE"; }

_blue_ufw() { show_page "UFW — Uncomplicated Firewall" \
"═══════════════════════════════════════════════════════════════
  UFW — Uncomplicated Firewall                         [BLUE]
═══════════════════════════════════════════════════════════════

  ENABLE / DISABLE
    # ufw enable
    # ufw disable

  STATUS
    # ufw status verbose

  LOGGING
    # ufw logging on
    # ufw logging off

  ALLOW / DENY RULES
    # ufw allow 22/tcp
    # ufw allow 80/tcp
    # ufw allow 443/tcp
    # ufw allow from <IP>
    # ufw allow all ssh
    # ufw deny 23/tcp
    # ufw delete <RULE_NUMBER>

  BACKUP UFW RULES
    # cp /lib/ufw/{user.rules,user6.rules} ./backup/

  RESET TO DEFAULTS
    # ufw reset"; }

_blue_winfw() { show_page "Windows Firewall — netsh advfirewall" \
"═══════════════════════════════════════════════════════════════
  Windows Firewall — netsh advfirewall               [BLUE]
═══════════════════════════════════════════════════════════════

  SHOW ALL RULES
    C:\> netsh advfirewall firewall show rule name=all

  ENABLE (all profiles)
    C:\> netsh advfirewall set currentprofile state on
    C:\> netsh advfirewall set publicprofile state on
    C:\> netsh advfirewall set privateprofile state on
    C:\> netsh advfirewall set domainprofile state on

  SET DEFAULT POLICY
    C:\> netsh advfirewall set currentprofile \\
         firewallpolicy blockinboundalways,allowoutbound

  ADD INBOUND ALLOW RULE
    C:\> netsh advfirewall firewall add rule \\
         name=\"MyApp\" dir=in action=allow \\
         program=\"C:\\MyApp\\MyApp.exe\" enable=yes

  ADD RULE WITH REMOTE IP RESTRICTION
    C:\> netsh advfirewall firewall add rule \\
         name=\"MyApp\" dir=in action=allow \\
         program=\"C:\\MyApp\\MyApp.exe\" enable=yes \\
         remoteip=157.60.0.1,172.16.0.0/16,LocalSubnet \\
         profile=domain

  ENABLE LOGGING
    C:\> netsh advfirewall set allprofile logging maxfilesize 4096
    C:\> netsh advfirewall set allprofile logging droppedconnections enable
    C:\> netsh advfirewall set allprofile logging allowedconnections enable

  VIEW FIREWALL LOG (PowerShell)
    PS C:\> Get-Content \\
         \$env:systemroot\\system32\\LogFiles\\Firewall\\pfirewall.log

  DISABLE (emergency/testing only)
    C:\> netsh advfirewall set allprofiles state off"; }

_blue_passwd_harden() { show_page "Password Hardening" \
"═══════════════════════════════════════════════════════════════
  Password Hardening                                   [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — Change password
    C:\> net user <USER> * /domain
    C:\> net user <USER> <NEW_PASSWORD>

  WINDOWS — Change remotely (PsPasswd)
    C:\> pspasswd.exe \\\\<IP> -u <USER> <NEWPASS>

  LINUX — Change password
    \$ passwd              (current user)
    \$ passwd bob          (specific user)
    \$ sudo passwd root    (root)

  SEND NTLMv2 ONLY — refuse LM & NTLM (reg)
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa \\
    /v lmcompatibilitylevel /t REG_DWORD /d 5 /f

  RESTRICT ANONYMOUS ACCESS
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa \\
    /v restrictanonymous /t REG_DWORD /d 1 /f

  BLOCK SAM ANONYMOUS ENUM
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa \\
    /v restrictanonymoussam /t REG_DWORD /d 1 /f

  DISABLE LMHASH (prevents Pass-the-Hash)
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa \\
    /f /v NoLMHash /t REG_DWORD /d 1

  REQUIRE UAC
    C:\> reg add \\
    HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System \\
    /v EnableLUA /t REG_DWORD /d 1 /f"; }

_blue_applocker() { show_page "AppLocker — Application Control" \
"═══════════════════════════════════════════════════════════════
  AppLocker — Application Control                      [BLUE]
═══════════════════════════════════════════════════════════════

  ENABLE SERVICE
    C:\> REG add \\
    \"HKLM\\SYSTEM\\CurrentControlSet\\services\\AppIDSvc\" \\
    /v Start /t REG_DWORD /d 2 /f
    C:\> shutdown.exe /r

  IMPORT POWERSHELL MODULE
    PS C:\> Import-Module AppLocker

  GET FILE INFO FOR EXECUTABLES
    PS C:\> Get-ApplockerFileInformation \\
            -Directory C:\\Windows\\System32\\ \\
            -Recurse -FileType Exe,Script

  CREATE ALLOW POLICY
    PS C:\> Get-ApplockerFileInformation \\
            -Directory C:\\Windows\\System32\\ \\
            -Recurse -FileType Exe,Script | \\
            New-AppLockerPolicy -RuleType Publisher,Hash \\
            -User Everyone -Optimize

  VIEW LOCAL POLICY
    PS C:\> Get-AppLockerPolicy -Local -Xml | Out-GridView

  AUDIT BLOCKED FILES
    PS C:\> Get-ApplockerFileInformation \\
            -Eventlog \\
            -Logname \"Microsoft-Windows-Applocker\\EXE and DLL\" \\
            -EventType Audited -Statistics

  GUI STEPS:
    1. Create GPO → Edit
    2. Computer Config → Policies → Windows Settings →
       Security Settings → Application Control → AppLocker
    3. Configure Rule Enforcement → Executable Rules
    4. Create New Rule → Publisher or Hash-based"; }

_blue_ipsec() { show_page "IPSEC Configuration" \
"═══════════════════════════════════════════════════════════════
  IPSEC Configuration                                  [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — Create local IPSEC policy
    C:\> netsh ipsec static add filter \\
         filterlist=MyIPsecFilter srcaddr=Any \\
         dstaddr=Any protocol=ANY

    C:\> netsh ipsec static add filteraction \\
         name=MyIPsecAction action=negotiate

    C:\> netsh ipsec static add policy \\
         name=MyIPsecPolicy assign=yes

    C:\> netsh ipsec static add rule \\
         name=MyIPsecRule policy=MyIPsecPolicy \\
         filterlist=MyIPsecFilter \\
         filteraction=MyIPsecAction conntype=all

  SHOW / STOP POLICY
    C:\> netsh ipsec static show policy name=MyIPsecPolicy
    C:\> netsh ipsec static set policy name=MyIPsecPolicy assign=no

  WINDOWS — Advanced Firewall IPSEC
    C:\> netsh advfirewall consec add rule name=\"IPSEC\" \\
         endpoint1=any endpoint2=any \\
         action=requireinrequireout qmsecmethods=default

  LINUX — Allow IPSEC in iptables
    # iptables -A INPUT -p esp -j ACCEPT
    # iptables -A INPUT -p ah -j ACCEPT
    # iptables -A INPUT -p udp --dport 500 -j ACCEPT
    # iptables -A INPUT -p udp --dport 4500 -j ACCEPT

  VERIFY SECURITY ASSOCIATIONS
    # setkey -D
    # setkey -DP"; }

_blue_reg_harden() { show_page "Registry Hardening — Windows" \
"═══════════════════════════════════════════════════════════════
  Registry Hardening — Windows                         [BLUE]
═══════════════════════════════════════════════════════════════

  DISABLE ADMIN SHARES (Workstations)
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters \\
    /f /v AutoShareWks /t REG_DWORD /d 0

  DISABLE ADMIN SHARES (Servers)
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters \\
    /f /v AutoShareServer /t REG_DWORD /d 0

  DISABLE IPV6
    C:\> reg add \\
    HKLM\\SYSTEM\\CurrentControlSet\\services\\TCPIP6\\Parameters \\
    /v DisabledComponents /t REG_DWORD /d 255 /f

  DISABLE RESTRICTED ADMIN RDP CACHE
    C:\> reg add \\
    HKLM\\System\\CurrentControlSet\\Control\\Lsa \\
    /v DisableRestrictedAdmin /t REG_DWORD /d 0 /f

  DISABLE RUN ONCE
    C:\> reg add \\
    HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer \\
    /v DisableLocalMachineRunOnce /t REG_DWORD /d 1

  REQUIRE UAC PERMISSION
    C:\> reg add \\
    HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System \\
    /v EnableLUA /t REG_DWORD /d 1 /f

  APPLY GROUP POLICY
    C:\> gpupdate /force
    C:\> gpupdate /sync

  AUDIT ALL (success + failure)
    C:\> auditpol /set /category:* \\
         /success:enable /failure:enable"; }

_blue_honeypot() { show_page "Honeypot Techniques" \
"═══════════════════════════════════════════════════════════════
  Honeypot Techniques                                  [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — Honey Ports (auto-block scanner IPs)
    C:\> for /L %%i in (1,1,1) do
         @for /f \"tokens=3\" %%j in
         ('netstat -nao ^| find \":3333\"') do
         netsh advfirewall firewall add rule
         name=\"HONEY_TOKEN\" dir=in remoteip=%%k
         localport=any protocol=TCP action=block
         > honeypot.bat
    C:\> honeypot.bat

  WINDOWS — Honey Hash (detect Mimikatz)
    Step 1: Create fake credential in memory
    C:\> runas /user:domain\\fakeadmin /netonly cmd.exe

    Step 2: Query remote access attempts
    C:\> wevtutil qe System \\
         /q:\"*[System[(EventID=20274)]]\" \\
         /f:text /rd:true /c:1

    Step 3: Query failed logins
    C:\> wevtutil qe Security \\
         /q:\"*[System[(EventID=4624 or EventID=4625)]]\"

  LINUX — Honey Port (auto-block with iptables)
    # while [ 1 ]; do
        IP=\$(nc -v -l -p 2222 2>&1 | grep from | \\
             cut -d[ -f3 | cut -d] -f1)
        iptables -A INPUT -p tcp -s \${IP} -j DROP
      done

  LINUX — Honey Ports Python Script
    # wget https://github.com/gchetrick/honeyports/...
    # python honeyports-0.5.py -p <PORT> -h <HOST_IP>

  LABREA TARPIT (slow down scanners)
    # apt-get install labrea
    # labrea -z -s -o -b -v -i eth0

  PASSIVE DNS MONITORING
    # apt-get install dnstop
    # dnstop -l 3 <INTERFACE>
    [Press 2 to show query names]"; }
