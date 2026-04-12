#!/usr/bin/env bash

# ─────────────────────────────────────────────
# dotfiles.sh — Dotfile deployment via symlinks
# ─────────────────────────────────────────────

BACKUP_DIR="${HOME}/.config-backup-$(date +%Y%m%d-%H%M%S)"

deploy_dotfiles_from_config() {
    # Usage: deploy_dotfiles_from_config <config.yaml>
    local config="$1"

    if [[ ! -f "${config}" ]]; then
        log_error "Config file not found: ${config}"
        return 1
    fi

    local -a dotfile_entries=()
    while IFS= read -r entry; do
        [[ -n "${entry}" ]] && dotfile_entries+=("${entry}")
    done < <(yaml_list "${config}" "dotfiles")

    if [[ ${#dotfile_entries[@]} -eq 0 ]]; then
        log_warn "No dotfiles declared in ${config}"
        return 0
    fi

    log_step "Deploying ${#dotfile_entries[@]} dotfile configs"

    for entry in "${dotfile_entries[@]}"; do
        local src="${DOTFILES_DIR}/${entry}"
        local dest="${HOME}/.config/${entry}"

        if [[ ! -d "${src}" ]]; then
            log_warn "Source not found: ${src} (skipped)"
            continue
        fi

        # Backup existing config if it's a real directory (not already a symlink)
        if [[ -d "${dest}" && ! -L "${dest}" ]]; then
            mkdir -p "${BACKUP_DIR}"
            log_info "Backing up existing ${dest} → ${BACKUP_DIR}/${entry}"
            mv "${dest}" "${BACKUP_DIR}/${entry}"
        elif [[ -L "${dest}" ]]; then
            # Remove old symlink
            rm -f "${dest}"
        fi

        # Create symlink
        ln -sf "${src}" "${dest}"
        log_success "Linked: ${src} → ${dest}"
    done

    # Make scripts executable
    find "${DOTFILES_DIR}" -name "*.sh" -exec chmod +x {} \;
    log_success "Made all .sh scripts executable"
}
