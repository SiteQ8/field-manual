#!/usr/bin/env bash
# modules/blue/forensics.sh

blue_forensics() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🧬 BLUE — Forensics  " \
            --menu "\n  Digital Forensics Techniques:\n" 18 65 5 \
            "1" "  🧠  Memory — Volatility analysis" \
            "2" "  💿  Disk — Imaging & analysis" \
            "3" "  🌐  Network — PCAP analysis" \
            "4" "  📋  Log Analysis — Parsing" \
            "5" "  🔪  File Carving — Recovery" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _blue_volatility ;;
            2) _blue_disk_forensics ;;
            3) _blue_net_forensics ;;
            4) _blue_log_analysis ;;
            5) _blue_file_carving ;;
        esac
    done
}

_blue_volatility() { show_page "Memory Forensics — Volatility" \
"═══════════════════════════════════════════════════════════════
  Memory Forensics — Volatility                        [BLUE]
═══════════════════════════════════════════════════════════════

  STEP 1 — IDENTIFY PROFILE
    # volatility -f memory.raw imageinfo
    # volatility -f memory.raw kdbgscan

  STEP 2 — PROCESS ANALYSIS
    # volatility -f memory.raw --profile=<PROFILE> pslist
    # volatility -f memory.raw --profile=<PROFILE> pstree
    # volatility -f memory.raw --profile=<PROFILE> psscan
    # volatility -f memory.raw --profile=<PROFILE> dlllist
    # volatility -f memory.raw --profile=<PROFILE> cmdline
    # volatility -f memory.raw --profile=<PROFILE> cmdscan
    # volatility -f memory.raw --profile=<PROFILE> consoles

  STEP 3 — NETWORK ANALYSIS
    # volatility -f memory.raw --profile=<PROFILE> netscan
    # volatility -f memory.raw --profile=<PROFILE> connscan

  STEP 4 — DETECT INJECTED CODE
    # volatility -f memory.raw --profile=<PROFILE> \\
      malfind -D ./dumps/

  STEP 5 — DUMP PROCESSES / FILES
    # volatility -f memory.raw --profile=<PROFILE> \\
      procdump -p <PID> -D ./dumps/
    # volatility -f memory.raw --profile=<PROFILE> \\
      memdump -p <PID> -D ./dumps/
    # volatility -f memory.raw --profile=<PROFILE> \\
      dumpfiles -Q <OFFSET> -D ./dumps/

  STEP 6 — CREDENTIALS
    # volatility -f memory.raw --profile=<PROFILE> hashdump
    # volatility -f memory.raw --profile=<PROFILE> lsadump

  VOLATILITY 3 — Equivalent commands
    # vol -f memory.raw windows.pslist
    # vol -f memory.raw windows.netscan
    # vol -f memory.raw windows.malfind
    # vol -f memory.raw windows.cmdline
    # vol -f memory.raw windows.dlllist
    # vol -f memory.raw windows.dumpfiles
    # vol -f memory.raw windows.hashdump"; }

_blue_disk_forensics() { show_page "Disk Forensics" \
"═══════════════════════════════════════════════════════════════
  Disk Forensics                                       [BLUE]
═══════════════════════════════════════════════════════════════

  CREATE DISK IMAGE
    # dd if=/dev/sda of=disk.dd bs=4M
    # dcfldd if=/dev/sda of=disk.dd hash=sha256 \\
      hashlog=hash.txt
    # ewfacquire /dev/sda -C Case1 -D Disk1 \\
      -t ./disk_image

  HASH VERIFICATION
    # sha256sum disk.dd > disk.dd.sha256
    # sha256sum -c disk.dd.sha256

  MOUNT IMAGE (read-only)
    # mount -o ro,loop disk.dd /mnt/image
    # mount -o ro,loop,offset=<OFFSET> disk.dd /mnt/part

  PARTITION TABLE
    # mmls disk.dd
    # fdisk -l disk.dd
    # parted disk.dd print

  FILE SYSTEM LISTING (Sleuth Kit)
    # fls -r disk.dd
    # fls -r -o <OFFSET> disk.dd

  RECOVER DELETED FILES
    # tsk_recover -e disk.dd /mnt/recovered/
    # photorec disk.dd           (GUI recovery)

  INODE DETAILS
    # istat disk.dd <INODE>
    # ils disk.dd                (list inodes)

  VOLUME SHADOW COPIES
    # vssadmin list shadows
    # vssadmin list shadowstorage

  TIMELINE CREATION
    # fls -r -m '/' disk.dd > bodyfile.txt
    # mactime -b bodyfile.txt -d > timeline.csv

  NTFS ANALYSIS
    # ntfsinfo -m /dev/sda
    # ntfsls -l /dev/sda"; }

_blue_net_forensics() { show_page "Network Forensics — PCAP Analysis" \
"═══════════════════════════════════════════════════════════════
  Network Forensics — PCAP Analysis                    [BLUE]
═══════════════════════════════════════════════════════════════

  OPEN PCAP IN WIRESHARK
    # wireshark capture.pcap

  QUICK STATS
    # capinfos capture.pcap

  FILTER AND EXPORT PCAP
    # tcpdump -r capture.pcap -w filtered.pcap \\
      'host 10.0.0.1 and port 80'

  EXTRACT HTTP OBJECTS (Wireshark)
    File → Export Objects → HTTP

  EXTRACT CREDENTIALS
    # tshark -r capture.pcap \\
      -Y 'http contains \"password\" or http contains \"passwd\"' \\
      -T fields -e http.file_data

  DNS QUERY ANALYSIS
    # tshark -r capture.pcap \\
      -Y 'dns.flags.response == 0' \\
      -T fields -e ip.src -e dns.qry.name

  TOP TALKERS
    # tshark -r capture.pcap -q \\
      -z conv,ip | head -20

  REASSEMBLE TCP STREAM
    # tcpflow -r capture.pcap -C -g

  DETECT PORT SCANS
    # tshark -r capture.pcap \\
      -Y 'tcp.flags.syn==1 and tcp.flags.ack==0' \\
      -T fields -e ip.src | sort | uniq -c | sort -rn

  DETECT SUSPICIOUS DNS (long names = DGA/C2)
    # tshark -r capture.pcap \\
      -Y 'dns.qry.name' -T fields -e dns.qry.name | \\
      awk 'length(\$0) > 50' | sort -u"; }

_blue_log_analysis() { show_page "Log Analysis" \
"═══════════════════════════════════════════════════════════════
  Log Analysis                                         [BLUE]
═══════════════════════════════════════════════════════════════

  GREP BASICS
    # grep 'pattern' file.log
    # grep -i 'error' file.log      (case insensitive)
    # grep -v '#' file.log          (exclude comments)
    # grep -E 'err|warn|crit' file.log

  COUNT OCCURRENCES
    # grep -c 'FAILED' auth.log
    # awk '{print \$1}' access.log | sort | uniq -c | sort -rn

  AWK — Extract fields
    # awk '{print \$1, \$7}' access.log   (IP and request)
    # awk -F: '{print \$1}' /etc/passwd   (usernames)

  FIND TOP IPs
    # awk '{print \$1}' /var/log/nginx/access.log | \\
      sort | uniq -c | sort -rn | head -20

  FIND TOP REQUESTS
    # awk '{print \$7}' /var/log/apache2/access.log | \\
      sort | uniq -c | sort -rn | head -20

  FIND 4xx ERRORS
    # awk '(\$9 >= 400)' /var/log/nginx/access.log

  TIME RANGE FILTER (e.g. between two dates)
    # awk '/2024-01-15/,/2024-01-16/' syslog

  DETECT BRUTE FORCE (SSH)
    # grep 'Failed password' /var/log/auth.log | \\
      awk '{print \$(NF-3)}' | sort | uniq -c | sort -rn

  WINDOWS LOG PARSING (PowerShell)
    PS C:\> Get-WinEvent -FilterHashtable \\
            @{LogName='Security'; Id=4625} | \\
            Select TimeCreated,Message | \\
            Export-Csv failed_logins.csv"; }

_blue_file_carving() { show_page "File Carving — Recovery" \
"═══════════════════════════════════════════════════════════════
  File Carving — Recovery                              [BLUE]
═══════════════════════════════════════════════════════════════

  FOREMOST
    # foremost -t all -i disk.dd -o ./carved/
    # foremost -t jpg,pdf,zip -i disk.dd -o ./carved/

  SCALPEL (faster, config-based)
    # vi /etc/scalpel/scalpel.conf   (uncomment file types)
    # scalpel disk.dd -o ./carved/

  BINWALK (firmware/embedded)
    # binwalk -e <FILE>
    # binwalk --dd='.*' <FILE>

  PHOTOREC (GUI recovery)
    # photorec disk.dd

  STRINGS — Extract text artifacts
    # strings -n 8 <FILE>
    # strings -el <FILE>              (Unicode)
    # strings <FILE> | grep -E 'http|ftp|@|password'

  HEXEDIT — Manual inspection
    # hexedit <FILE>
    # xxd <FILE> | less
    # xxd <FILE> | grep -A2 'FFD8FF'  (JPEG magic bytes)

  COMMON MAGIC BYTES (file signatures)
    JPEG:  FF D8 FF
    PNG:   89 50 4E 47 0D 0A 1A 0A
    PDF:   25 50 44 46
    ZIP:   50 4B 03 04
    EXE:   4D 5A (MZ)
    ELF:   7F 45 4C 46
    GIF:   47 49 46 38
    RAR:   52 61 72 21 1A 07"; }
