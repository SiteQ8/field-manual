#!/usr/bin/env bash
# modules/blue/respond.sh

blue_respond() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🚨 BLUE — Respond  " \
            --menu "\n  Incident Response Procedures:\n" 18 65 6 \
            "1" "  🪟  IR Triage — Windows" \
            "2" "  🐧  IR Triage — Linux" \
            "3" "  🌐  Network Isolation" \
            "4" "  💾  Evidence Collection" \
            "5" "  🦠  Malware Analysis" \
            "6" "  🔍  Memory Forensics (quick)" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_ir_windows ;;
            2) _blue_ir_linux ;;
            3) _blue_isolation ;;
            4) _blue_evidence ;;
            5) _blue_malware ;;
            6) _blue_mem_quick ;;
        esac
    done
}

_blue_ir_windows() { show_page "IR Triage — Windows" \
"═══════════════════════════════════════════════════════════════
  IR Triage — Windows                                  [BLUE]
═══════════════════════════════════════════════════════════════

  RUNNING PROCESSES
    C:\> tasklist /v
    C:\> wmic process get name,executablepath,processid
    C:\> wmic process get name,executablepath,commandline

  NETWORK CONNECTIONS (with PID)
    C:\> netstat -naob
    C:\> netstat -ano | findstr ESTABLISHED

  SCHEDULED TASKS
    C:\> schtasks /query /fo LIST /v
    C:\> schtasks /query /fo CSV > tasks.csv

  STARTUP ITEMS (Registry)
    C:\> reg query HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run
    C:\> reg query HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run

  RECENTLY MODIFIED FILES (PowerShell)
    PS C:\> Get-ChildItem C:\\Users -Recurse -Force | \\
            Sort LastWriteTime -Desc | Select -first 50

  TEMP & APPDATA EXECUTABLES
    PS C:\> Get-ChildItem \\$env:TEMP, \\$env:APPDATA \\
            -Recurse -Include *.exe,*.dll,*.bat,*.ps1

  LOGGED IN USERS
    C:\> query user

  OPEN SHARES
    C:\> net share
    C:\> net session

  SERVICES
    C:\> sc query type= all state= all
    C:\> Get-Service | Where-Object {\\$_.Status -eq 'Running'}

  RECENT EVENT LOGS (PowerShell)
    PS C:\> Get-EventLog -LogName Security -Newest 50
    PS C:\> Get-WinEvent -FilterHashtable \\
            @{LogName='Security'; Id=4624,4625,4688} | \\
            Select -First 100"; }

_blue_ir_linux() { show_page "IR Triage — Linux" \
"═══════════════════════════════════════════════════════════════
  IR Triage — Linux                                    [BLUE]
═══════════════════════════════════════════════════════════════

  RUNNING PROCESSES
    # ps auxf
    # ps -eo pid,ppid,user,cmd --forest
    # top -bn1

  NETWORK CONNECTIONS
    # ss -natp
    # netstat -natp
    # lsof -i

  LISTENING PORTS + PROGRAMS
    # ss -tlnp
    # netstat -tlnp

  SUSPICIOUS CONNECTIONS (check for C2)
    # netstat -anp | grep ESTABLISHED | \\
      awk '{print \$5}' | cut -d: -f1 | \\
      sort | uniq -c | sort -rn

  SCHEDULED JOBS
    # crontab -l
    # cat /etc/crontab
    # ls -la /etc/cron.d/ /etc/cron.daily/

  RECENTLY MODIFIED SYSTEM FILES
    # find /etc /bin /sbin /usr -mtime -7 -type f
    # find / -newer /tmp -type f 2>/dev/null | \\
      grep -v proc | head -50

  LOADED KERNEL MODULES
    # lsmod
    # modinfo <MODULE>

  ACTIVE USERS
    # w
    # who -a
    # last -20

  SUID / SGID FILES
    # find / -perm -4000 -o -perm -2000 \\
      -type f 2>/dev/null

  BASH HISTORY
    # cat ~/.bash_history
    # cat /home/*/.bash_history 2>/dev/null

  OPEN FILES BY PROCESS
    # lsof -p <PID>
    # lsof +D /tmp"; }

_blue_isolation() { show_page "Network Isolation" \
"═══════════════════════════════════════════════════════════════
  Network Isolation                                    [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — Isolate host (block all inbound/outbound)
    C:\> netsh advfirewall set allprofiles \\
         firewallpolicy blockinboundalways,blockoutbound

  WINDOWS — Re-enable after investigation
    C:\> netsh advfirewall set allprofiles \\
         firewallpolicy blockinboundalways,allowoutbound

  WINDOWS — Disconnect network adapter
    C:\> netsh interface set interface \\
         name=\"<ADAPTER_NAME>\" admin=disabled

  LINUX — Drop all traffic immediately
    # iptables -P INPUT DROP
    # iptables -P OUTPUT DROP
    # iptables -P FORWARD DROP
    # iptables -F

  LINUX — Allow only SSH from IR workstation
    # iptables -A INPUT -s <IR_WORKSTATION_IP> \\
      -p tcp --dport 22 -j ACCEPT
    # iptables -A OUTPUT -d <IR_WORKSTATION_IP> \\
      -p tcp --sport 22 -j ACCEPT

  LINUX — Take down interface
    # ip link set eth0 down
    # ifconfig eth0 down

  ACTIVE DIRECTORY — Disable computer account
    PS C:\> Disable-ADAccount -Identity <COMPUTER>\\$

  VLAN ISOLATION (on switch)
    # (Switch CLI) interface <PORT>
    # switchport access vlan <QUARANTINE_VLAN>"; }

_blue_evidence() { show_page "Evidence Collection" \
"═══════════════════════════════════════════════════════════════
  Evidence Collection                                  [BLUE]
═══════════════════════════════════════════════════════════════

  DISK IMAGE (bit-for-bit)
    # dd if=/dev/sda of=/mnt/usb/disk.dd bs=4M
    # dd if=/dev/sda | gzip -9 > disk.dd.gz

  HASH EVIDENCE (establish chain of custody)
    # sha256sum disk.dd > disk.dd.sha256
    # sha256sum disk.dd.gz > disk.dd.gz.sha256
    # md5sum disk.dd >> disk.dd.sha256

  MEMORY DUMP — LINUX (LiME)
    # insmod lime.ko \"path=/mnt/usb/mem.lime format=lime\"

  MEMORY DUMP — Windows (WinPMem)
    C:\> winpmem_mini.exe memory.raw

  MEMORY DUMP — DumpIt
    C:\> DumpIt.exe /O memory.dmp

  EXPORT WINDOWS LOGS
    C:\> wevtutil epl Security security.evtx
    C:\> wevtutil epl System system.evtx
    C:\> wevtutil epl Application app.evtx

  EXPORT REGISTRY
    C:\> reg export HKLM hklm_backup.reg
    C:\> reg export HKCU hkcu_backup.reg

  COLLECT VOLATILE DATA FIRST (order of volatility)
    1. Running processes
    2. Network connections
    3. Active users / sessions
    4. Memory contents
    5. Running services
    6. Open files
    7. Disk / filesystem
    8. Event logs

  COMPRESS + TIMESTAMP COLLECTION
    # tar -czf evidence_\$(date +%Y%m%d_%H%M%S).tar.gz \\
      /var/log /tmp \\
      /etc/crontab /etc/passwd /etc/shadow"; }

_blue_malware() { show_page "Malware Analysis Basics" \
"═══════════════════════════════════════════════════════════════
  Malware Analysis Basics                              [BLUE]
═══════════════════════════════════════════════════════════════

  STATIC ANALYSIS — File info
    # file <MALWARE>
    # strings -n 8 <MALWARE>
    # objdump -d <MALWARE>
    # readelf -a <MALWARE>
    # exiftool <MALWARE>
    # binwalk <MALWARE>

  HASH IDENTIFICATION (VirusTotal)
    # sha256sum <MALWARE>
    # md5sum <MALWARE>
    [Submit hash to https://www.virustotal.com]

  PACKER DETECTION
    # PEiD <MALWARE>
    # Detect-It-Easy (DIE): die <MALWARE>

  WINDOWS — PE analysis
    C:\> sigcheck.exe -e -u -vt -s <DIR>
    C:\> strings.exe -accepteula <MALWARE>

  ONLINE SANDBOXES
    https://any.run        — Interactive sandbox
    https://app.any.run    — Threat intelligence
    https://hybrid-analysis.com
    https://cuckoo.cert.ee

  YARA — Scan with rules
    # yara malware_rules.yar <TARGET_DIR>
    # yara -r malware_rules.yar /

  LINUX — Trace system calls
    # strace -f -e trace=all -p <PID>
    # ltrace <MALWARE>

  WINDOWS — API monitor
    Process Monitor (ProcMon) — sysinternals
    API Monitor — http://www.rohitab.com/apimonitor

  NETWORK ANALYSIS (in sandbox)
    # tcpdump -i eth0 -w malware_traffic.pcap
    # wireshark malware_traffic.pcap"; }

_blue_mem_quick() { show_page "Memory Forensics — Quick Reference" \
"═══════════════════════════════════════════════════════════════
  Memory Forensics — Quick Reference                   [BLUE]
═══════════════════════════════════════════════════════════════

  VOLATILITY 2 — Identify profile
    # volatility -f memory.raw imageinfo
    # volatility -f memory.raw kdbgscan

  VOLATILITY 2 — Core commands
    # volatility -f memory.raw --profile=<PROFILE> pslist
    # volatility -f memory.raw --profile=<PROFILE> pstree
    # volatility -f memory.raw --profile=<PROFILE> psscan
    # volatility -f memory.raw --profile=<PROFILE> cmdline
    # volatility -f memory.raw --profile=<PROFILE> cmdscan
    # volatility -f memory.raw --profile=<PROFILE> consoles
    # volatility -f memory.raw --profile=<PROFILE> netscan
    # volatility -f memory.raw --profile=<PROFILE> connscan

  VOLATILITY 2 — Dump & analyze
    # volatility -f memory.raw --profile=<PROFILE> \\
      malfind -D ./dumps/
    # volatility -f memory.raw --profile=<PROFILE> \\
      procdump -p <PID> -D ./dumps/
    # volatility -f memory.raw --profile=<PROFILE> \\
      memdump -p <PID> -D ./dumps/
    # volatility -f memory.raw --profile=<PROFILE> dlllist

  VOLATILITY 3 — Commands
    # vol -f memory.raw windows.pslist
    # vol -f memory.raw windows.netscan
    # vol -f memory.raw windows.malfind
    # vol -f memory.raw windows.cmdline
    # vol -f memory.raw windows.dlllist
    # vol -f memory.raw windows.dumpfiles

  STRINGS FROM MEMORY
    # strings -el memory.raw > strings_unicode.txt
    # strings -eb memory.raw > strings_bigendian.txt
    # grep -Ea 'http|ftp|\.exe|PASS' strings_unicode.txt"; }
