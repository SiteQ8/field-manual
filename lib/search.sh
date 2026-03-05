#!/usr/bin/env bash
# lib/search.sh — global full-text search across all module data files

global_search() {
    local query
    query=$(dialog \
        --backtitle "$(backtitle)" \
        --title "  🔍 Search All Commands  " \
        --inputbox "\n  Enter keyword (e.g. nmap, ssh, mimikatz, iptables):\n" \
        9 55 \
        3>&1 1>&2 2>&3) || return 0
    [[ -z "$query" ]] && return 0

    local results_tmp; results_tmp=$(mktemp /tmp/fm_res_XXXXXX.txt)
    local menu_tmp;    menu_tmp=$(mktemp   /tmp/fm_menu_XXXXXX.txt)
    local count=0

    # Search all .dat files
    while IFS='|' read -r section label cmd || [[ -n "$section" ]]; do
        if echo "$label $cmd" | grep -qi "$query" 2>/dev/null; then
            count=$((count + 1))
            printf '%d|[%s] %s\n' "$count" "$section" "$label"  >> "$menu_tmp"
            printf '=RESULT%d=\n[%s] %s\n%s\n' \
                   "$count" "$section" "$label" "$cmd"           >> "$results_tmp"
        fi
    done < <(find "$MOD_DIR" -name "*.dat" -exec cat {} \; 2>/dev/null)

    if [[ $count -eq 0 ]]; then
        dialog --backtitle "$(backtitle)" --title " 🔍 No Results " \
               --msgbox "\n  Nothing found for: \"$query\"\n\n  Try: nmap, ssh, tcpdump, mimikatz, iptables\n" 10 48
        rm -f "$results_tmp" "$menu_tmp"
        return 0
    fi

    # Build menu args
    local menu_args=()
    while IFS='|' read -r n lbl; do
        menu_args+=("$n" "$lbl")
    done < "$menu_tmp"

    local sel
    sel=$(dialog \
        --backtitle "$(backtitle)" \
        --title "  🔍 \"$query\"  ($count results)  " \
        --menu "\n  Select a result:\n" 22 70 14 \
        "${menu_args[@]}" \
        3>&1 1>&2 2>&3) || { rm -f "$results_tmp" "$menu_tmp"; return 0; }

    # Extract selected result block
    local block
    block=$(awk "/^=RESULT${sel}=/{found=1;next} found && /^=RESULT/{exit} found{print}" "$results_tmp")
    show_page "Search: $query" "$block"

    rm -f "$results_tmp" "$menu_tmp"
}
