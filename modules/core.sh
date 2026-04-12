#!/usr/bin/env bash

# ─────────────────────────────────────────────
# core.sh — Shared utilities and helpers
# ─────────────────────────────────────────────

# Resolve the root directory of the project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
LOG_DIR="${SCRIPT_DIR}/logs"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Log file for current run
LOG_FILE="${LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"

# ── Colors ────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Logging ───────────────────────────────────
log_info()    { echo -e "${BLUE}[INFO]${NC}    $*" | tee -a "${LOG_FILE}"; }
log_success() { echo -e "${GREEN}[OK]${NC}      $*" | tee -a "${LOG_FILE}"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}    $*" | tee -a "${LOG_FILE}"; }
log_error()   { echo -e "${RED}[ERROR]${NC}   $*" | tee -a "${LOG_FILE}"; }
log_step()    { echo -e "\n${CYAN}${BOLD}▸ $*${NC}\n" | tee -a "${LOG_FILE}"; }

# ── Checks ────────────────────────────────────
require_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root. Use a normal user with sudo."
        exit 1
    fi
}

require_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is designed for Arch Linux only."
        exit 1
    fi
}

require_command() {
    local cmd="$1"
    if ! command -v "${cmd}" &>/dev/null; then
        log_error "Required command '${cmd}' not found."
        return 1
    fi
}

# ── YAML Parsing ──────────────────────────────
# Uses yq to read YAML config files.
# Falls back to a basic grep parser if yq is unavailable.

yaml_list() {
    # Usage: yaml_list <file> <key>
    # Returns a newline-separated list of values under a YAML array key.
    local file="$1" key="$2"

    if command -v yq &>/dev/null; then
        yq -r ".${key}[]? // empty" "${file}" 2>/dev/null
    else
        # Fallback: basic parser for simple YAML arrays
        _yaml_list_fallback "${file}" "${key}"
    fi
}

yaml_value() {
    # Usage: yaml_value <file> <key>
    # Returns a single scalar value.
    local file="$1" key="$2"

    if command -v yq &>/dev/null; then
        yq -r ".${key} // empty" "${file}" 2>/dev/null
    else
        _yaml_value_fallback "${file}" "${key}"
    fi
}

_yaml_list_fallback() {
    # Simple line-by-line YAML list parser (handles `key:\n  - val` format)
    local file="$1" key="$2"
    local in_block=false depth=0

    # Convert dotted key to last segment for matching
    local match_key="${key##*.}"

    while IFS= read -r line; do
        # Detect block start
        if [[ "${line}" =~ ^[[:space:]]*${match_key}:[[:space:]]*$ ]]; then
            in_block=true
            continue
        fi

        if ${in_block}; then
            # Still in list items (lines starting with "  - ")
            if [[ "${line}" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
                echo "${BASH_REMATCH[1]}"
            elif [[ "${line}" =~ ^[[:space:]]*$ ]]; then
                continue
            else
                # New key encountered, stop
                break
            fi
        fi
    done < "${file}"
}

_yaml_value_fallback() {
    local file="$1" key="$2"
    local match_key="${key##*.}"

    grep -E "^[[:space:]]*${match_key}:" "${file}" 2>/dev/null \
        | head -1 \
        | sed 's/.*:[[:space:]]*//'
}

# ── System Update ─────────────────────────────
setup_core() {
    log_step "Updating system"
    sudo pacman -Syu --noconfirm 2>&1 | tee -a "${LOG_FILE}"
    log_success "System updated"
}

# ── Ensure yay is available ───────────────────
ensure_yay() {
    if ! command -v yay &>/dev/null; then
        log_info "yay not found, installing..."
        bash "${SCRIPT_DIR}/scripts/install_yay.sh" 2>&1 | tee -a "${LOG_FILE}"
    else
        log_success "yay is already installed"
    fi
}
