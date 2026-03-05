#!/usr/bin/env bash
# modules/red/osint.sh

red_osint() {
    while true; do
        local c
        c=$(dialog --backtitle "$(backtitle)" \
            --title "  🌐 RED — OSINT & Recon  " \
            --menu "\n  Intelligence Gathering:\n" 18 65 6 \
            "1" "  🌐  Network Recon — DNS, WHOIS" \
            "2" "  🔧  Recon Tools — Frameworks" \
            "3" "  🔍  Google Dorks — Search operators" \
            "4" "  👤  People Search — OSINT sites" \
            "5" "  🔬  Subdomain Enum" \
            "6" "  📡  Passive Recon — Shodan etc." \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) _red_dns_recon ;;
            2) _red_recon_tools ;;
            3) _red_google_dorks ;;
            4) _red_people_search ;;
            5) _red_subdomains ;;
            6) _red_passive ;;
        esac
    done
}

_red_dns_recon() { show_page "Network Recon — DNS & WHOIS" \
"═══════════════════════════════════════════════════════════════
  Network Recon — DNS & WHOIS                          [RED]
═══════════════════════════════════════════════════════════════

  WHOIS
    # whois <DOMAIN>
    # whois <IP>

  DNS LOOKUP (ALL records)
    # dig <DOMAIN> ANY
    # dig <DOMAIN> MX
    # dig <DOMAIN> NS
    # dig <DOMAIN> TXT
    # host <DOMAIN>
    # nslookup <DOMAIN>

  REVERSE DNS LOOKUP
    # dig -x <IP>
    # host <IP>
    # nslookup <IP>

  DNS ZONE TRANSFER
    # dig axfr <DOMAIN> @<NS_IP>
    # host -t axfr -l <DOMAIN> <NS_IP>
    # nslookup; server <NS>; set type=ANY; ls -d <DOMAIN>

  FIND NAME SERVERS
    # dig NS <DOMAIN>
    # nslookup -type=NS <DOMAIN>

  SPF / DMARC RECORDS
    # dig TXT <DOMAIN> | grep spf
    # dig TXT _dmarc.<DOMAIN>

  MX RECORDS
    # dig MX <DOMAIN>
    # nmap -p 25 --script smtp-commands <MAIL_SERVER>

  CERTIFICATE TRANSPARENCY
    # curl -s 'https://crt.sh/?q=<DOMAIN>&output=json' | jq .
    # curl -s 'https://crt.sh/?q=%25.<DOMAIN>&output=json' | \\
      jq '.[].name_value' | sort -u

  USEFUL SITES
    dnsstuff.com/tools      DNS tools
    network-tools.com       Network tools
    centralops.net          CentralOps
    shodan.io               Shodan
    viz.greynoise.io        GreyNoise
    mxtoolbox.com           MxToolBox
    iana.org/numbers        IANA lookups"; }

_red_recon_tools() { show_page "Recon Tools & Frameworks" \
"═══════════════════════════════════════════════════════════════
  Recon Tools & Frameworks                             [RED]
═══════════════════════════════════════════════════════════════

  THEHARVESTER
    # theHarvester -d <DOMAIN> -b all -l 500
    # theHarvester -d <DOMAIN> -b google,bing,linkedin
    # theHarvester -d <DOMAIN> -b all -f output.html

  RECON-NG
    # recon-ng
    [recon-ng] > marketplace install all
    [recon-ng] > workspaces create <PROJECT>
    [recon-ng] > modules search domains
    [recon-ng] > modules load recon/domains-hosts/hackertarget
    [recon-ng] > options set SOURCE <DOMAIN>
    [recon-ng] > run
    [recon-ng] > show hosts

  MALTEGO
    maltego.com — GUI link analysis tool
    Use Transforms: domain → IPs, emails, people

  SPIDERFOOT (automated)
    # pip install spiderfoot
    # spiderfoot -l 127.0.0.1:5001
    # Open http://127.0.0.1:5001 → New Scan

  AMASS (subdomain + ASN recon)
    # amass enum -d <DOMAIN>
    # amass enum -brute -d <DOMAIN>
    # amass intel -org \"<COMPANY_NAME>\"
    # amass intel -asn <ASN_NUMBER>

  FOCA (document metadata)
    github.com/ElevenPaths/FOCA
    Extract metadata from: doc, pdf, xls, ppt, odt

  CREEPY (geolocation OSINT)
    Geolocate from social media posts"; }

_red_google_dorks() { show_page "Google Dorks — Search Operators" \
"═══════════════════════════════════════════════════════════════
  Google Dorks — Search Operators                      [RED]
═══════════════════════════════════════════════════════════════

  BASIC OPERATORS
    site:<URL>                Search only within a domain
    filetype:<EXT>            Search for specific file type
    intitle:\"<TEXT>\"          Search page title
    inurl:\"<TEXT>\"            Search in URL
    intext:\"<TEXT>\"           Search in page body
    link:<URL>                Pages linking to URL
    related:<URL>             Pages related to URL
    cache:<URL>               Google's cached version
    numrange:<N>..<M>         Search within number range

  SENSITIVE FILE DISCOVERY
    filetype:env DB_PASSWORD
    filetype:log username password
    filetype:sql \"INSERT INTO\" \"VALUES\"
    filetype:conf \"password\"
    filetype:yml database password
    filetype:xml \"password\"

  ADMIN PANELS
    intitle:\"admin panel\" site:<DOMAIN>
    inurl:\"/admin/login\" site:<DOMAIN>
    inurl:\"/wp-admin\" site:<DOMAIN>
    inurl:\"/phpmyadmin\" site:<DOMAIN>

  EXPOSED FILES
    intitle:\"index of\" site:<DOMAIN>
    intitle:\"index of\" /backup
    intitle:\"index of\" /uploads

  EMAIL / CREDENTIAL HARVESTING
    \"@<DOMAIN>\" filetype:xls
    \"@<DOMAIN>\" filetype:pdf

  CAMERAS / NETWORK DEVICES
    inurl:\"ViewerFrame?Mode=\"
    intitle:\"Hikvision\" inurl:\"/ISAPI\"

  REFERENCE
    https://www.exploit-db.com/google-hacking-database"; }

_red_people_search() { show_page "People Search & OSINT Sites" \
"═══════════════════════════════════════════════════════════════
  People Search & OSINT Sites                          [RED]
═══════════════════════════════════════════════════════════════

  PEOPLE SEARCH ENGINES
    peekyou.com             PeekYou
    spokeo.com              Spokeo
    pipl.com                Pipl (professional)
    intelius.com            Intelius
    publicrecords.searchsystems.net  Public Records

  SOCIAL MEDIA OSINT
    linkedin.com/in/<USER>   LinkedIn profile
    twitter.com/<USER>       Twitter profile
    instagram.com/<USER>     Instagram
    github.com/<USER>        GitHub code
    facebook.com/<USER>      Facebook

  BREACH / CREDENTIAL LOOKUP
    haveibeenpwned.com       Email breach check
    dehashed.com             Credential search
    leakcheck.io             Leak checker
    intelx.io                Intelligence X

  SEARCH ENGINES
    google.com               Standard search
    bing.com                 Microsoft search
    yandex.com               Russian search
    duckduckgo.com           Private search
    startpage.com            Anonymous search

  TECHNICAL OSINT
    shodan.io                Device search
    censys.io                Host/cert search
    fofa.info                Asset search (China)
    greynoise.io             IP reputation
    ipinfo.io                IP geolocation
    bgp.he.net               BGP/ASN lookup
    robtex.com               DNS lookup

  REFERENCE SITES
    vulnerabilityassessment.co.uk
    securitysift.com/passive-reconnaissance/
    pentest-standard.org
    osintframework.com"; }

_red_subdomains() { show_page "Subdomain Enumeration" \
"═══════════════════════════════════════════════════════════════
  Subdomain Enumeration                                [RED]
═══════════════════════════════════════════════════════════════

  AMASS (most comprehensive)
    # amass enum -d <DOMAIN>
    # amass enum -brute -d <DOMAIN> -w subdomains.txt
    # amass enum -passive -d <DOMAIN>

  SUBFINDER
    # subfinder -d <DOMAIN>
    # subfinder -d <DOMAIN> -o subs.txt
    # subfinder -dL domains.txt

  DNSRECON
    # dnsrecon -d <DOMAIN> -t brt -D subdomains.txt
    # dnsrecon -d <DOMAIN> -t axfr

  DNSX (resolver)
    # cat subs.txt | dnsx -resp -a -cname -mx -ns

  GOBUSTER (DNS mode)
    # gobuster dns -d <DOMAIN> \\
      -w /usr/share/wordlists/SecLists/Discovery/DNS/bitquark-subdomains-top100000.txt

  CERTIFICATE TRANSPARENCY
    # curl -s 'https://crt.sh/?q=%25.<DOMAIN>&output=json' | \\
      jq -r '.[].name_value' | sort -u | grep '<DOMAIN>'

    # curl -s 'https://api.certspotter.com/v1/issuances?\\
      domain=<DOMAIN>&include_subdomains=true&expand=dns_names' | \\
      jq '.[].dns_names[]' | tr -d '\"' | sort -u

  PASSIVE (no DNS queries)
    # theHarvester -d <DOMAIN> -b all
    https://securitytrails.com
    https://dnsdumpster.com
    https://findsubdomains.com

  RESOLVE + FILTER LIVE
    # cat subs.txt | massdns -r resolvers.txt -t A -o S | \\
      awk '{print \$1}' | sort -u"; }

_red_passive() { show_page "Passive Recon — Shodan & Tools" \
"═══════════════════════════════════════════════════════════════
  Passive Recon — Shodan, Censys, Fofa                 [RED]
═══════════════════════════════════════════════════════════════

  SHODAN (shodan.io)
    org:\"<COMPANY_NAME>\"     Assets by org name
    hostname:<DOMAIN>         Assets by hostname
    ssl:<DOMAIN>              SSL cert match
    port:3389 country:US      RDP in US
    product:\"Apache\"          Apache servers
    vuln:CVE-2021-44228       Log4Shell exposed
    net:<IP_RANGE>            IP range scan

    Shodan CLI:
    # pip install shodan
    # shodan init <API_KEY>
    # shodan search 'org:\"<COMPANY>\"'
    # shodan host <IP>
    # shodan download results.json.gz 'port:22 country:US'

  CENSYS (censys.io)
    services.port:443
    parsed.subject_dn:\"<COMPANY>\"
    autonomous_system.name:\"<COMPANY>\"

  FOFA (fofa.info)
    org=\"<COMPANY>\"
    domain=\"<DOMAIN>\"
    cert.subject.cn=\"<DOMAIN>\"

  GREYNOISE (greynoise.io)
    Identify scanners, bots, noisy IPs
    # curl 'https://api.greynoise.io/v3/community/<IP>'

  BINARYEDGE (binaryedge.io)
    Similar to Shodan with more data

  SPYSE (spyse.com)
    Domain, IP, ASN, cert search"; }
