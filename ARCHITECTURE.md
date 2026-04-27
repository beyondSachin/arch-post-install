# Architecture Guide

This document provides a technical deep-dive into how the Arch Post-Installation Workbench is structured and how it operates.

## Design Philosophy

- **Modularity**: Every major system component (packages, dotfiles, users) is encapsulated in its own module.
- **Declarative Configuration**: The system state is defined in YAML files, separating "what" to install from "how" to install it.
- **Robustness**: Error handling, logging, and pre-flight checks are baked into the core engine.
- **User-Centric**: Designed to be run by a normal user with `sudo`, ensuring correct ownership and permissions.

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `config/` | YAML definitions for packages, services, and dotfiles. |
| `modules/` | Bash scripts containing the logic for each installation phase. |
| `dotfiles/` | The actual configuration files to be deployed to `~/.config/`. |
| `scripts/` | Standalone helper scripts for complex setups (e.g., yay, fish, fonts). |
| `logs/` | Timestamped logs for every installation run. |

## Module Breakdown

### `core.sh`
The "Engine" of the workbench.
- **YAML Parser**: Contains a fallback regex-based parser if `yq` is missing.
- **Logging**: Standardized `log_info`, `log_success`, `log_error` functions.
- **Checks**: Internet verification, root/sudo checks, and Arch Linux verification.

### `packages.sh`
Handles software installation.
- Checks if a package is already installed to skip redundant work.
- Supports both `pacman` (official) and `yay` (AUR) packages.

### `dotfiles.sh`
Manages configuration deployment.
- Creates symlinks from the repository to `~/.config/`.
- **Automatic Backups**: If a real directory exists where a symlink should be, it moves it to a timestamped backup folder.

### `services.sh`
Manages systemd units.
- Automatically handles both `.service` and `.timer` units.
- Uses `enable --now` to both enable on boot and start immediately.

### `users.sh`
Configures the user environment.
- Sets the default shell (`chsh`).
- Manages group memberships (`usermod`).
- Sets system-wide locale, timezone, and keymap.

### `hyprland.sh`
The desktop environment orchestrator.
- High-level module that calls other modules specifically for the Hyprland environment.
- Handles GTK/theming defaults and XDG user directories.

## Installation Sequence

```mermaid
sequenceDiagram
    participant U as User
    participant I as install.sh
    participant C as core.sh
    participant M as Modules
    participant S as System

    U->>I: Run ./install.sh
    I->>C: Load utilities & check environment
    C-->>I: Environment OK
    I->>U: Request Mode (full/base/dotfiles)
    U->>I: Mode Selected
    I->>C: setup_core (Update system, install yq)
    C->>S: pacman -Syu
    I->>M: Execute modules for Mode
    M->>S: Install packages, symlink dotfiles, enable services
    I-->>U: Installation Complete
```

## Adding New Features

1. **New Package**: Add it to `config/base.yaml` (system-wide) or `config/hyprland.yaml` (desktop-specific).
2. **New Dotfile**: Place the folder in `dotfiles/` and add the name to the `dotfiles` list in `config/hyprland.yaml`.
3. **New Logic**: If you need new installation logic, create a new script in `modules/` and source it in `install.sh`.
