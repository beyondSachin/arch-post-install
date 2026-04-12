#!/usr/bin/env bash

# ─────────────────────────────────────────────
# packages.sh — Package installation module
# ─────────────────────────────────────────────

install_packages_from_config() {
    # Usage: install_packages_from_config <config.yaml>
    local config="$1"

    if [[ ! -f "${config}" ]]; then
        log_error "Config file not found: ${config}"
        return 1
    fi

    # ── Pacman packages ───────────────────────
    local -a pacman_pkgs=()
    while IFS= read -r pkg; do
        [[ -n "${pkg}" ]] && pacman_pkgs+=("${pkg}")
    done < <(yaml_list "${config}" "packages.pacman")

    if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
        log_step "Installing ${#pacman_pkgs[@]} pacman packages"
        log_info "Packages: ${pacman_pkgs[*]}"
        sudo pacman -S --needed --noconfirm "${pacman_pkgs[@]}" 2>&1 | tee -a "${LOG_FILE}"
        log_success "Pacman packages installed"
    else
        log_warn "No pacman packages found in ${config}"
    fi

    # ── AUR packages ──────────────────────────
    local -a aur_pkgs=()
    while IFS= read -r pkg; do
        [[ -n "${pkg}" ]] && aur_pkgs+=("${pkg}")
    done < <(yaml_list "${config}" "packages.aur")

    if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
        ensure_yay
        log_step "Installing ${#aur_pkgs[@]} AUR packages"
        log_info "Packages: ${aur_pkgs[*]}"
        yay -S --needed --noconfirm "${aur_pkgs[@]}" 2>&1 | tee -a "${LOG_FILE}"
        log_success "AUR packages installed"
    fi
}

install_base_packages() {
    log_step "Installing base packages"
    install_packages_from_config "${CONFIG_DIR}/base.yaml"
}
