#!/usr/bin/env bash

# ─────────────────────────────────────────────
# Arch Linux Post-Installation Script
# Entry point — Hyprland desktop setup
# ─────────────────────────────────────────────

set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all modules
source "${SCRIPT_DIR}/modules/core.sh"
source "${SCRIPT_DIR}/modules/packages.sh"
source "${SCRIPT_DIR}/modules/services.sh"
source "${SCRIPT_DIR}/modules/users.sh"
source "${SCRIPT_DIR}/modules/dotfiles.sh"
source "${SCRIPT_DIR}/modules/hyprland.sh"

# ── Banner ────────────────────────────────────
show_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║    Arch Linux Post-Install Script    ║"
    echo "  ║         Hyprland Edition             ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BLUE}Log file:${NC} ${LOG_FILE}"
    echo ""
}

# ── Mode Selection ────────────────────────────
select_mode() {
    echo -e "${BOLD}What would you like to install?${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Full install    — Base + Hyprland + dotfiles"
    echo -e "  ${CYAN}2)${NC} Base only       — Packages & system config, no DE"
    echo -e "  ${CYAN}3)${NC} Dotfiles only   — Deploy configs to ~/.config/"
    echo -e "  ${CYAN}0)${NC} Exit"
    echo ""
    read -rp "  Choice [1-3]: " choice
    echo ""

    case "${choice}" in
        1) MODE="full" ;;
        2) MODE="base" ;;
        3) MODE="dotfiles" ;;
        0) echo "Bye!"; exit 0 ;;
        *) log_error "Invalid choice."; exit 1 ;;
    esac
}

# ── Confirmation ──────────────────────────────
confirm_install() {
    echo -e "${YELLOW}${BOLD}Install mode: ${MODE}${NC}"
    echo -e "This will:"

    case "${MODE}" in
        full)
            echo -e "  • Update the system (pacman -Syu)"
            echo -e "  • Install base + Hyprland packages"
            echo -e "  • Enable system services"
            echo -e "  • Configure user account"
            echo -e "  • Deploy dotfiles (symlinked to ~/.config/)"
            ;;
        base)
            echo -e "  • Update the system (pacman -Syu)"
            echo -e "  • Install base packages"
            echo -e "  • Enable base services"
            echo -e "  • Configure user account"
            ;;
        dotfiles)
            echo -e "  • Deploy Hyprland dotfiles (symlinked to ~/.config/)"
            ;;
    esac

    echo ""
    read -rp "  Proceed? [y/N]: " yn
    case "${yn}" in
        [Yy]*) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
}

# ── Main ──────────────────────────────────────
main() {
    show_banner

    # Pre-flight checks
    require_arch
    require_root

    # Mode selection (can be overridden via CLI arg)
    if [[ $# -ge 1 ]]; then
        MODE="$1"
    else
        select_mode
    fi

    confirm_install

    log_step "Starting '${MODE}' installation"

    case "${MODE}" in
        full)
            setup_core
            install_base_packages
            enable_base_services
            setup_users
            ensure_yay
            setup_hyprland
            ;;
        base)
            setup_core
            install_base_packages
            enable_base_services
            setup_users
            ;;
        dotfiles)
            deploy_dotfiles_from_config "${CONFIG_DIR}/hyprland.yaml"
            ;;
        *)
            log_error "Unknown mode: ${MODE}"
            echo "Usage: ./install.sh [full|base|dotfiles]"
            exit 1
            ;;
    esac

    # Done
    echo ""
    log_step "Installation complete!"
    echo -e "  ${GREEN}${BOLD}✔ Mode:${NC}  ${MODE}"
    echo -e "  ${GREEN}${BOLD}✔ Log:${NC}   ${LOG_FILE}"
    echo ""
    echo -e "  ${YELLOW}Reboot recommended:${NC} ${BOLD}sudo reboot${NC}"
    echo ""
}

main "$@"
