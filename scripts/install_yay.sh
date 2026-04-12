#!/usr/bin/env bash

# ─────────────────────────────────────────────
# install_yay.sh — Install yay AUR helper
# ─────────────────────────────────────────────

set -e

if command -v yay &>/dev/null; then
    echo "[OK] yay is already installed."
    exit 0
fi

echo "[INFO] Installing yay AUR helper..."

# Ensure dependencies
sudo pacman -S --needed --noconfirm base-devel git

# Build in a temporary directory
TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

git clone https://aur.archlinux.org/yay.git "${TMPDIR}/yay"
cd "${TMPDIR}/yay"
makepkg -si --noconfirm

echo "[OK] yay installed successfully."
