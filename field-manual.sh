#!/usr/bin/env bash
# =============================================================================
#  ██████╗ ████████╗███████╗███╗   ███╗    ██╗
#  ██╔══██╗╚══██╔══╝██╔════╝████╗ ████║    ██║
#  ██████╔╝   ██║   █████╗  ██╔████╔██║    ██║
#  ██╔══██╗   ██║   ██╔══╝  ██║╚██╔╝██║    ╚═╝
#  ██║  ██║   ██║   ██║     ██║ ╚═╝ ██║    ██╗
#  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝     ╚═╝    ╚═╝
#  Red & Blue Team Field Manual: Interactive TUI
# =============================================================================
#  Author  : Ali AlEnezi <Site@hotmail.com>
#  GitHub  : https://github.com/SiteQ8/field-manual
#  Based on: BLUE (Alan White & Ben Clark)
#            RED v2 (Ben Clark & Nick Downer)
#  License : MIT
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
export LIB_DIR="$SCRIPT_DIR/lib"
export MOD_DIR="$SCRIPT_DIR/modules"
export VERSION="1.0.0"

source "$LIB_DIR/colors.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/search.sh"

# ── Dependency check ─────────────────────────────────────────────────────────
check_deps() {
    local missing=()
    command -v dialog &>/dev/null || missing+=("dialog")
    command -v bash   &>/dev/null || missing+=("bash")
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[✗] Missing: ${missing[*]}${NC}"
        echo -e "    Install: ${YLW}sudo apt-get install ${missing[*]}${NC}"
        exit 1
    fi
    # Optional clipboard
    if   command -v xclip  &>/dev/null; then CLIP_CMD="xclip -selection clipboard"
    elif command -v xsel   &>/dev/null; then CLIP_CMD="xsel --clipboard --input"
    elif command -v pbcopy &>/dev/null; then CLIP_CMD="pbcopy"
    else                                     CLIP_CMD=""
    fi
    export CLIP_CMD
}

# ── Main menu ─────────────────────────────────────────────────────────────────
main_menu() {
    while true; do
        local choice
        choice=$(dialog \
            --clear \
            --backtitle "$(backtitle)" \
            --title "┤ ⚡ Field Manual v${VERSION} ├" \
            --menu "\n  Choose a section or feature:\n" \
            20 62 8 \
            "1" "  🔵  BLUE  ──  Blue Team Field Manual" \
            "2" "  🔴  RED  ──  Red Team Field Manual v2" \
            "3" "  🔍  Search  ── Search all commands" \
            "4" "  📋  Cheatsheet ─ Quick reference" \
            "5" "  🌐  Ports  ── Common ports & protocols" \
            "6" "  ℹ️   About  ── Help & info" \
            "q" "  🚪  Quit" \
            3>&1 1>&2 2>&3) || { clear; bye; }

        case "$choice" in
            1) source "$MOD_DIR/blue/menu.sh"; blue_menu ;;
            2) source "$MOD_DIR/red/menu.sh"; red_menu ;;
            3) global_search ;;
            4) source "$MOD_DIR/blue/quick_ref.sh"; quick_ref_menu ;;
            5) source "$MOD_DIR/red/ports.sh"; ports_menu ;;
            6) about_screen ;;
            q) clear; bye ;;
        esac
    done
}

bye() {
    echo -e "\n${CYN}  Stay safe out there. 🛡️${NC}\n"
    exit 0
}

about_screen() {
    dialog \
        --backtitle "$(backtitle)" \
        --title "  About Field Manual  " \
        --msgbox "\n\
  ┌────────────────────────────────────────┐\n\
  │     FIELD MANUAL TUI  v${VERSION}            │\n\
  │  Red & Blue Team Interactive Reference │\n\
  ├────────────────────────────────────────┤\n\
  │                                        │\n\
  │  📘 SiteQ8 Blue Team Tools      │\n\
  │     Alan White & Ben Clark             │\n\
  │                                        │\n\
  │  📕 RED v2 — Red Team Field Manual    │\n\
  │     Ben Clark & Nick Downer            │\n\
  │                                        │\n\
  │  Author : Ali AlEnezi                  │\n\
  │  GitHub : github.com/SiteQ8            │\n\
  │  Email  : Site@hotmail.com             │\n\
  │  Built  : bash + dialog                │\n\
  │  License: MIT                          │\n\
  │                                        │\n\
  │  ↑↓ Navigate  ENTER Select  ESC Back   │\n\
  └────────────────────────────────────────┘\n" \
        24 50
}

check_deps
main_menu
