#!/usr/bin/env bash

# ─────────────────────────────────────────────
# setup_zsh.sh — Install and configure Zsh
# ─────────────────────────────────────────────

set -e

echo "[INFO] Setting up Zsh..."

# Install zsh
sudo pacman -S --needed --noconfirm zsh

# Install Oh My Zsh (unattended)
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    echo "[INFO] Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "[OK] Oh My Zsh installed."
else
    echo "[OK] Oh My Zsh already installed."
fi

# Install popular plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    echo "[OK] zsh-autosuggestions installed."
fi

# zsh-syntax-highlighting
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    echo "[OK] zsh-syntax-highlighting installed."
fi

# Set Zsh as default shell
if [[ "$(getent passwd "${USER}" | cut -d: -f7)" != "$(which zsh)" ]]; then
    echo "[INFO] Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "[OK] Default shell changed to Zsh."
else
    echo "[OK] Zsh is already the default shell."
fi

echo "[OK] Zsh setup complete."
