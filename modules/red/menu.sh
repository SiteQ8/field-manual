#!/usr/bin/env bash
# modules/red/menu.sh

red_menu() {
    while true; do
        local c
        c=$(dialog --clear --backtitle "$(backtitle)" \
            --title "  🔴 SiteQ8 Red Team Tools  " \
            --menu "\n  Select a category:\n" 24 65 11 \
            "1"  "  🌐  OSINT       — Recon & intelligence" \
            "2"  "  🪟  Windows     — Enumeration & exploitation" \
            "3"  "  🐧  Linux       — Enumeration & exploitation" \
            "4"  "  🍎  MacOS       — Enumeration" \
            "5"  "  🌍  Ports       — Common ports & protocols" \
            "6"  "  💣  Exploitation — Web, Metasploit, payloads" \
            "7"  "  🎯  Post-Exploit — Lateral movement & loot" \
            "8"  "  🔑  Credentials — Mimikatz, hashes, Kerberos" \
            "9"  "  🕳️   Tunneling   — Pivoting & proxies" \
            "10" "  📜  Scripting   — PowerShell, Bash, Python" \
            "11" "  💡  Tips        — Tricks & reverse shells" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1)  source "$MOD_DIR/red/osint.sh";    red_osint     ;;
            2)  source "$MOD_DIR/red/windows.sh";  red_windows   ;;
            3)  source "$MOD_DIR/red/linux.sh";    red_linux     ;;
            4)  source "$MOD_DIR/red/macos.sh";    red_macos     ;;
            5)  ports_menu ;;
            6)  source "$MOD_DIR/red/exploit.sh";  red_exploit   ;;
            7)  source "$MOD_DIR/red/postex.sh";   red_postex    ;;
            8)  source "$MOD_DIR/red/creds.sh";    red_creds     ;;
            9)  source "$MOD_DIR/red/tunneling.sh"; red_tunneling ;;
            10) source "$MOD_DIR/red/scripting.sh"; red_scripting ;;
            11) source "$MOD_DIR/red/tips.sh";     red_tips      ;;
        esac
    done
}
