#!/usr/bin/env bash
# lib/ui.sh — dialog wrappers & display helpers

backtitle() {
    echo "⚡ Field Manual v${VERSION}  |  Blue + Red Team  |  github.com/SiteQ8/field-manual  |  ESC = back"
}

# show_page TITLE CONTENT
# Displays scrollable text; offers copy-to-clipboard
show_page() {
    local title="$1"
    local content="$2"
    local tmp; tmp=$(mktemp /tmp/fm_XXXXXX.txt)
    printf '%s\n' "$content" > "$tmp"

    local action
    action=$(dialog \
        --backtitle "$(backtitle)" \
        --title "  $title  " \
        --textbox "$tmp" 0 0 \
        3>&1 1>&2 2>&3) || true

    rm -f "$tmp"

    # After textbox exits (pressing q/ESC), offer clipboard copy
    if [[ -n "${CLIP_CMD:-}" ]]; then
        if dialog \
            --backtitle "$(backtitle)" \
            --title "  📋 Copy  " \
            --yesno "\n  Copy commands to clipboard?" \
            7 40 2>&1 >/dev/tty; then
            printf '%s\n' "$content" | $CLIP_CMD
            dialog --backtitle "$(backtitle)" \
                   --title " ✅ " --infobox "\n  Copied!\n" 5 22
            sleep 0.8
        fi
    fi
}

# show_info TITLE CONTENT  (no copy prompt)
show_info() {
    local title="$1"; local content="$2"
    local tmp; tmp=$(mktemp /tmp/fm_XXXXXX.txt)
    printf '%s\n' "$content" > "$tmp"
    dialog --backtitle "$(backtitle)" --title "  $title  " --textbox "$tmp" 0 0 || true
    rm -f "$tmp"
}
