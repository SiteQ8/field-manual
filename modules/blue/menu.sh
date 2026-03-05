#!/usr/bin/env bash
# modules/blue/menu.sh

blue_menu() {
    while true; do
        local c
        c=$(dialog --clear --backtitle "$(backtitle)" \
            --title "  🔵 SiteQ8 Blue Team Tools  " \
            --menu "\n  NIST Cybersecurity Framework:\n" 22 64 9 \
            "1" "  📋  Preparation — Key documents & IR plan" \
            "2" "  🔎  Identify   — Scanning & enumeration" \
            "3" "  🛡️   Protect   — Firewalls & hardening" \
            "4" "  👁️   Detect    — Network & log monitoring" \
            "5" "  🚨  Respond   — Incident response" \
            "6" "  🏥  Recover   — System recovery" \
            "7" "  🖥️   OS Cheats — Windows & Linux" \
            "8" "  🧬  Forensics — Memory & disk analysis" \
            "9" "  🔑  Event IDs — Key Windows event IDs" \
            3>&1 1>&2 2>&3) || return 0
        case "$c" in
            1) source "$MOD_DIR/blue/preparation.sh"; blue_preparation  ;;
            2) source "$MOD_DIR/blue/identify.sh";    blue_identify      ;;
            3) source "$MOD_DIR/blue/protect.sh";     blue_protect       ;;
            4) source "$MOD_DIR/blue/detect.sh";      blue_detect        ;;
            5) source "$MOD_DIR/blue/respond.sh";     blue_respond       ;;
            6) source "$MOD_DIR/blue/recover.sh";     blue_recover       ;;
            7) source "$MOD_DIR/blue/os_cheats.sh";   blue_os_cheats     ;;
            8) source "$MOD_DIR/blue/forensics.sh";   blue_forensics     ;;
            9) source "$MOD_DIR/blue/event_ids.sh";   blue_event_ids     ;;
        esac
    done
}
