#!/bin/bash
#
# ReconFlow Installer
# Installs every external tool the modules/ scripts shell out to.
# Safe to re-run: already-installed tools are skipped unless --force is passed.

set -uo pipefail

# -----------------------------
# Options
# -----------------------------
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -h|--help)
            echo "Usage: $0 [--force]"
            echo "  --force   Reinstall tools even if already present on PATH"
            exit 0
            ;;
    esac
done

# -----------------------------
# Colors / logging
# -----------------------------
GREEN="\e[32m"; CYAN="\e[36m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"

info()  { echo -e "${CYAN}[*]${RESET} $*"; }
ok()    { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
fail()  { echo -e "${RED}[✗]${RESET} $*"; }

FAILED_TOOLS=()

# -----------------------------
# Requirements (single source of truth)
# -----------------------------
APT_PACKAGES=(
    nmap dnsutils git curl wget golang-go
    python3 python3-pip python3-venv pipx
    build-essential seclists
    amass ffuf hakrawler gospider
)

# name -> go module path
declare -A GO_TOOLS=(
    [subfinder]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    [assetfinder]="github.com/tomnomnom/assetfinder@latest"
    [httpx]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    [katana]="github.com/projectdiscovery/katana/cmd/katana@latest"
    [gau]="github.com/lc/gau/v2/cmd/gau@latest"
    [waybackurls]="github.com/tomnomnom/waybackurls@latest"
)

# name -> pipx package spec
declare -A PIPX_TOOLS=(
    [dirsearch]="dirsearch"
    [arjun]="arjun"
    [paramspider]="git+https://github.com/devanshbatham/ParamSpider.git"
)

SECLISTS_DIR="/usr/share/seclists"

# -----------------------------
# OS check
# -----------------------------
if ! command -v apt-get >/dev/null 2>&1; then
    fail "This installer supports Debian/Kali-based systems (apt-get not found)."
    exit 1
fi

# -----------------------------
# Sudo check (needed for apt only)
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    info "Requesting sudo for system package installation..."
    sudo -v || { fail "sudo access is required to install system packages."; exit 1; }
fi

# -----------------------------
# System packages (apt)
# -----------------------------
info "Updating apt package lists..."
sudo apt-get update -qq

info "Installing system packages: ${APT_PACKAGES[*]}"
if sudo apt-get install -y -qq "${APT_PACKAGES[@]}"; then
    ok "System packages installed."
else
    fail "Some system packages failed to install."
    FAILED_TOOLS+=("apt-packages")
fi

# -----------------------------
# Go environment
# -----------------------------
GOBIN_DIR="$(go env GOPATH 2>/dev/null)/bin"
GOBIN_DIR="${GOBIN_DIR:-$HOME/go/bin}"
mkdir -p "$GOBIN_DIR"

for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [[ -f "$RC" ]] || continue
    if ! grep -q "$GOBIN_DIR" "$RC" 2>/dev/null; then
        echo "export PATH=\"$GOBIN_DIR:\$PATH\"" >> "$RC"
        info "Added $GOBIN_DIR to PATH in $RC"
    fi
done
export PATH="$GOBIN_DIR:$HOME/.local/bin:$PATH"

# -----------------------------
# Go-based tools
# -----------------------------
for tool in "${!GO_TOOLS[@]}"; do
    if [[ $FORCE -eq 0 ]] && command -v "$tool" >/dev/null 2>&1; then
        ok "$tool already installed, skipping."
        continue
    fi

    info "Installing $tool via go install..."
    if go install "${GO_TOOLS[$tool]}" 2>/dev/null; then
        ok "$tool installed."
    else
        fail "$tool failed to install."
        FAILED_TOOLS+=("$tool")
    fi
done

# -----------------------------
# pipx-based (Python) tools
# -----------------------------
pipx ensurepath >/dev/null 2>&1 || true

for tool in "${!PIPX_TOOLS[@]}"; do
    if [[ $FORCE -eq 0 ]] && command -v "$tool" >/dev/null 2>&1; then
        ok "$tool already installed, skipping."
        continue
    fi

    info "Installing $tool via pipx..."
    if pipx install --force "${PIPX_TOOLS[$tool]}" >/dev/null 2>&1; then
        ok "$tool installed."
    else
        fail "$tool failed to install."
        FAILED_TOOLS+=("$tool")
    fi
done

# -----------------------------
# Wordlists (seclists)
# -----------------------------
if [[ -d "$SECLISTS_DIR" ]]; then
    ok "seclists present at $SECLISTS_DIR"
else
    warn "seclists not found at $SECLISTS_DIR, cloning from GitHub instead..."
    if sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR" 2>/dev/null; then
        ok "seclists cloned to $SECLISTS_DIR"
    else
        fail "Could not provision seclists wordlists."
        FAILED_TOOLS+=("seclists")
    fi
fi

# -----------------------------
# Verification summary
# -----------------------------
echo
echo "=========================================="
echo "        Installation Summary"
echo "=========================================="

ALL_BINS=(nmap dig git amass ffuf hakrawler gospider subfinder assetfinder httpx katana gau waybackurls dirsearch arjun paramspider)

for bin in "${ALL_BINS[@]}"; do
    if command -v "$bin" >/dev/null 2>&1; then
        ok "$bin"
    else
        fail "$bin"
    fi
done

[[ -d "$SECLISTS_DIR" ]] && ok "seclists ($SECLISTS_DIR)" || fail "seclists ($SECLISTS_DIR)"

echo "=========================================="

if [[ ${#FAILED_TOOLS[@]} -eq 0 ]]; then
    ok "All ReconFlow dependencies are installed."
else
    warn "Failed/incomplete: ${FAILED_TOOLS[*]}"
    warn "Re-run this script, or install the failed tools manually."
fi

warn "Open a new shell (or 'source ~/.zshrc') so PATH updates take effect."
