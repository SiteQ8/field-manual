#!/usr/bin/env bash
# install.sh — Field Manual Installer
# Author: Ali AlEnezi <Site@hotmail.com>
# GitHub: https://github.com/SiteQ8/field-manual

set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/field-manual"
BIN_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; NC='\033[0m'

banner() {
    echo -e "${CYN}"
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║     ⚡ Field Manual — Blue + Red Team v2      ║"
    echo "  ║        Installer v1.0.0                    ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_deps() {
    echo -e "${BLD}[*] Checking dependencies...${NC}"
    local missing=()

    command -v bash   &>/dev/null || missing+=("bash")
    command -v dialog &>/dev/null || missing+=("dialog")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YLW}[!] Missing: ${missing[*]}${NC}"
        echo -e "${YLW}[*] Attempting to install...${NC}"
        install_deps "${missing[@]}"
    else
        echo -e "${GRN}[✓] All dependencies satisfied${NC}"
    fi
}

install_deps() {
    local pkgs=("$@")
    if   command -v apt-get &>/dev/null; then sudo apt-get install -y "${pkgs[@]}"
    elif command -v dnf     &>/dev/null; then sudo dnf install -y "${pkgs[@]}"
    elif command -v yum     &>/dev/null; then sudo yum install -y "${pkgs[@]}"
    elif command -v pacman  &>/dev/null; then sudo pacman -S --noconfirm "${pkgs[@]}"
    elif command -v brew    &>/dev/null; then brew install "${pkgs[@]}"
    else
        echo -e "${RED}[✗] Cannot auto-install. Please install manually: ${pkgs[*]}${NC}"
        exit 1
    fi
}

do_install() {
    echo -e "${BLD}[*] Installing to: ${INSTALL_DIR}${NC}"

    mkdir -p "${INSTALL_DIR}" "${BIN_DIR}"

    # Copy all files
    cp -r "${SCRIPT_DIR}/." "${INSTALL_DIR}/"

    # Make scripts executable
    find "${INSTALL_DIR}" -name "*.sh" -exec chmod +x {} \;
    chmod +x "${INSTALL_DIR}/field-manual.sh"

    # Create wrapper in ~/.local/bin
    cat > "${BIN_DIR}/field-manual" << EOF
#!/usr/bin/env bash
exec "${INSTALL_DIR}/field-manual.sh" "\$@"
EOF
    chmod +x "${BIN_DIR}/field-manual"

    echo -e "${GRN}[✓] Installed successfully!${NC}"
}

check_path() {
    if ! echo "${PATH}" | grep -q "${BIN_DIR}"; then
        echo -e "${YLW}[!] ${BIN_DIR} is not in your PATH${NC}"
        echo -e "${YLW}    Add this to ~/.bashrc or ~/.zshrc:${NC}"
        echo -e "${CYN}    export PATH=\"\${PATH}:${BIN_DIR}\"${NC}"
    else
        echo -e "${GRN}[✓] ${BIN_DIR} is in PATH${NC}"
    fi
}

uninstall() {
    echo -e "${YLW}[*] Uninstalling Field Manual...${NC}"
    rm -rf "${INSTALL_DIR}"
    rm -f "${BIN_DIR}/field-manual"
    echo -e "${GRN}[✓] Uninstalled${NC}"
    exit 0
}

# ─── Main ────────────────────────────────────────────────────
banner

case "${1:-install}" in
    uninstall|remove|-u) uninstall ;;
    install|-i|*)
        check_deps
        do_install
        check_path
        echo ""
        echo -e "${GRN}${BLD}  ✅ Installation complete!${NC}"
        echo ""
        echo -e "  Run with: ${CYN}field-manual${NC}"
        echo ""
        ;;
esac
