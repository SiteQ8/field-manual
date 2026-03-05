#!/usr/bin/env bash
# modules/red/ports.sh

ports_menu() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🌐 Ports & Protocols Reference  " \
            --menu "\n  Select port category:\n" 18 65 6 \
            "1" "  🔢  Common Ports — Top 50" \
            "2" "  🏥  Healthcare Protocols" \
            "3" "  🏭  SCADA / ICS Protocols" \
            "4" "  🌐  IPv4 Reference — Subnets" \
            "5" "  🌍  IPv6 Reference" \
            "6" "  📡  TTL Fingerprinting" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _ports_common ;;
            2) _ports_healthcare ;;
            3) _ports_scada ;;
            4) _ports_ipv4 ;;
            5) _ports_ipv6 ;;
            6) _ports_ttl ;;
        esac
    done
}

_ports_common() { show_page "Common Ports — Top 50" \
"═══════════════════════════════════════════════════════════════
  Common Ports                                         [RED]
═══════════════════════════════════════════════════════════════

  PORT   SERVICE
  ─────  ────────────────────────────────
  20     FTP (Data Connection)
  21     FTP (Control Connection)
  22     SSH / SCP
  23     Telnet
  25     SMTP
  49     TACACS
  53     DNS
  67-68  DHCP / BOOTP
  69     TFTP (UDP)
  80     HTTP
  88     Kerberos
  110    POP3
  111    RPC / NFS (portmapper)
  123    NTP
  135    MS RPC
  137    NetBIOS Name Service
  138    NetBIOS Datagram
  139    NetBIOS Session / SMB
  143    IMAP
  161    SNMP
  179    BGP
  389    LDAP
  443    HTTPS
  445    SMB (Direct)
  465    SMTPS
  500    ISAKMP / IKE (IPSEC)
  514    Syslog / RSH
  520    RIP
  546    DHCPv6 Client
  547    DHCPv6 Server
  587    SMTP (submission)
  636    LDAPS
  902    VMware Server
  993    IMAPS
  995    POP3S
  1080   SOCKS Proxy
  1194   OpenVPN
  1433   MS-SQL Server
  1434   MS-SQL Monitor
  1521   Oracle DB
  2049   NFS
  3128   Squid Proxy
  3268   LDAP Global Catalog
  3269   LDAPS Global Catalog
  3306   MySQL
  3389   RDP (Remote Desktop)
  4444   Metasploit Default
  4500   IPSEC NAT Traversal
  5432   PostgreSQL
  5900   VNC
  5985   WinRM (HTTP)
  5986   WinRM (HTTPS)
  6379   Redis
  6667   IRC
  8080   HTTP Alternate
  8443   HTTPS Alternate
  8888   Jupyter Notebook
  9200   Elasticsearch
  27017  MongoDB"; }

_ports_healthcare() { show_page "Healthcare Protocols & Ports" \
"═══════════════════════════════════════════════════════════════
  Healthcare Protocols & Ports                         [RED]
═══════════════════════════════════════════════════════════════

  PORT   SERVICE
  ─────  ─────────────────────────────────
  20     FTP Data
  21     FTP Control
  22     SSH / SCP
  23     Telnet
  25     SMTP
  49     TACACS
  53     DNS
  67/68  DHCP / BOOTP
  69     TFTP (Medical imaging transfer)
  80     HTTP
  104    DICOM (medical imaging)
  110    POP3
  111    NFS Portmapper
  119    NNTP
  135    MS RPC
  137    NetBIOS Name
  138    NetBIOS Datagram
  139    SMB / NetBIOS Session
  143    IMAP
  161    SNMP (medical device management)
  162    SNMP Trap
  389    LDAP
  443    HTTPS
  445    SMB Direct
  1433   MSSQL (common in healthcare EHR)
  2181   Apache ZooKeeper
  2575   HL7 (Health Level 7)
  3306   MySQL
  3389   RDP
  4100   HL7 over TLS
  5985   WinRM
  6129   Dameware Mini Remote
  8080   HTTP Alt
  8443   HTTPS Alt
  11112  DICOM Alt"; }

_ports_scada() { show_page "SCADA / ICS Protocols & Ports" \
"═══════════════════════════════════════════════════════════════
  SCADA / ICS Protocols & Ports                        [RED]
═══════════════════════════════════════════════════════════════

  PORT        SERVICE
  ─────────   ─────────────────────────────────
  80          HTTP (many HMI web interfaces)
  102         S7Comm (Siemens S7 PLC)
  443         OPC UA XML (HTTPS)
  502         Modbus TCP (most common ICS protocol)
  530         RPC
  593         HTTP RPC
  789         Red Lion Controls
  1089-1091   Foundation Fieldbus HSE (UDP/TCP)
  1911        Niagara Fox
  2222        EtherNet/IP (UDP)
  4000        ROC Plus (UDP/TCP)
  4840        OPC UA Discovery Server
  9600        OMRON FINS
  11001-11005 GE SRTP
  18245-18246 GE EGD
  20000       DNP3 (Distributed Network Protocol)
  20547       ProConOs
  34962-34964 PROFINET (UDP/TCP)
  34980       EtherCAT (UDP)
  44818       EtherNet/IP (UDP/TCP)
  47808       BACnet (Building Automation)
  55000       FL-net
  55001-55003 FL-net

  IMPORTANT PROTOCOLS
  ───────────────────
  Modbus     — Most widely deployed ICS protocol
  DNP3       — Common in electric utilities + water
  PROFINET   — Siemens industrial Ethernet
  EtherNet/IP — Rockwell/Allen-Bradley
  BACnet     — Building automation (HVAC, lighting)
  OPC UA     — Machine-to-machine communication

  SHODAN QUERIES (find exposed ICS)
  ───────────────────────────────────
  port:502        (Modbus)
  port:102        (Siemens S7)
  port:20000      (DNP3)
  port:44818      (EtherNet/IP)
  port:47808      (BACnet)"; }

_ports_ipv4() { show_page "IPv4 Reference — Subnets & Ranges" \
"═══════════════════════════════════════════════════════════════
  IPv4 Reference — Classful Ranges                     [RED]
═══════════════════════════════════════════════════════════════

  CLASSFUL RANGES
    0.0.0.0   – 127.255.255.255    Class A
    128.0.0.0 – 191.255.255.255    Class B
    192.0.0.0 – 223.255.255.255    Class C
    224.0.0.0 – 239.255.255.255    Class D (Multicast)
    240.0.0.0 – 255.255.255.255    Class E (Reserved)

  RESERVED PRIVATE RANGES (RFC1918)
    10.0.0.0    – 10.255.255.255   Class A
    172.16.0.0  – 172.31.255.255   Class B
    192.168.0.0 – 192.168.255.255  Class C

  SUBNET REFERENCE
    CIDR  Netmask            Hosts
    ────  ─────────────────  ──────────
    /8    255.0.0.0          16,777,214
    /16   255.255.0.0        65,534
    /24   255.255.255.0      254
    /25   255.255.255.128    126
    /26   255.255.255.192    62
    /27   255.255.255.224    30
    /28   255.255.255.240    14
    /29   255.255.255.248    6
    /30   255.255.255.252    2
    /32   255.255.255.255    1 (host)

  CALCULATE SUBNET RANGE
    Given: 1.1.1.101/28

    /28 = 255.255.255.240
    256 - 240 = 16 → ranges of 16
    Ranges: 1.1.1.0, 1.1.1.16, 1.1.1.32, ...
    Host falls in: 1.1.1.96 – 1.1.1.111

  LOOPBACK
    127.0.0.0/8   Loopback range
    127.0.0.1     Standard loopback

  LINK-LOCAL
    169.254.0.0/16  APIPA (auto-assigned when no DHCP)"; }

_ports_ipv6() { show_page "IPv6 Reference" \
"═══════════════════════════════════════════════════════════════
  IPv6 Reference                                       [RED]
═══════════════════════════════════════════════════════════════

  BROADCAST / MULTICAST ADDRESSES
    ff02::1    All link-local nodes
    ff01::2    Node-local routers
    ff02::2    All link-local routers
    ff05::2    Site-local routers

  INTERFACE ADDRESSES
    fe80::           Link-local (non-routable)
    2001::           Routable (global unicast)
    ::a.b.c.d        IPv4-compatible IPv6
    ::ffff:a.b.c.d   IPv4-mapped IPv6

  RANGES
    2000::/3     Global Unicast
    fc00::/7     Unique Local (private)
    fe80::/10    Link-Local
    ff00::/8     Multicast
    ::/128       Unspecified
    ::1/128      Loopback

  NOTATION RULES
    Leading zeros can be omitted:  0042 → 42
    Consecutive zeros compressed:  :: (once per address)
    Example: 2001:0db8:0000:0000:0000:0000:0000:0001
          = 2001:db8::1

  CONVERT IPv4 TO IPv6
    # python3 -c \"import socket; print(socket.getaddrinfo('192.168.1.1',None,socket.AF_INET6))\"

  NMAP IPv6 SCAN
    # nmap -6 <IPv6_ADDRESS>
    # nmap -6 -sV fe80::1%eth0"; }

_ports_ttl() { show_page "TTL Fingerprinting" \
"═══════════════════════════════════════════════════════════════
  TTL Fingerprinting                                   [RED]
═══════════════════════════════════════════════════════════════

  TYPICAL DEFAULT TTL VALUES
    OS / Device              Default TTL
    ─────────────────────────────────────
    Linux (most)             64
    macOS / BSD              64
    Windows 7/8/10/11        128
    Windows XP               128
    Windows Server           128
    Cisco Routers            255
    Cisco Switches           255
    Solaris                  255
    AIX                      255
    HP-UX                    255

  HOW TO USE
    # Ping target and observe TTL:
    ping -c 4 <TARGET>

    # Each hop reduces TTL by 1
    # So if you see TTL=119 → likely Windows (128 - 9 hops = 119)
    # If you see TTL=55 → likely Linux (64 - 9 hops = 55)

  NMAP OS DETECTION (more accurate)
    nmap -O <TARGET>
    nmap -A <TARGET>

  TTL IN TCPDUMP
    tcpdump -v -i eth0 icmp | grep ttl"; }
