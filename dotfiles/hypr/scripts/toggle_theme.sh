#!/bin/bash

# Apply theme globally to Hyprland, Waybar, Kitty, Rofi, and GTK

THEMES_DIR="$HOME/.config/theme"
HYPR_THEME="$HOME/.config/hypr/theme.conf"
WAYBAR_COLORS="$HOME/.config/waybar/colors.css"
KITTY_THEME="$HOME/.config/kitty/theme.conf"
ROFI_COLORS="$HOME/.config/rofi/colors.rasi"

apply_theme() {
    local STR="$1"
    
    # GTK / System
    if [ "$STR" == "dark" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        notify-send "Theme Switched" "Dark Mode Activated (Macchiato)" -i weather-clear-night-symbolic
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
        notify-send "Theme Switched" "Light Mode Activated (Latte)" -i weather-clear-symbolic
    fi

    echo "Applying $STR theme..."
    
    # Hyprland
    cp "$THEMES_DIR/$STR/hypr.conf" "$HYPR_THEME"
    # Note: Hyprland auto-reloads sourced config modifications immediately.

    # Waybar
    cp "$THEMES_DIR/$STR/waybar.css" "$WAYBAR_COLORS"
    pkill -SIGUSR2 waybar

    # Kitty
    cp "$THEMES_DIR/$STR/kitty.conf" "$KITTY_THEME"
    killall -USR1 kitty 2>/dev/null || true

    # Rofi
    cp "$THEMES_DIR/$STR/rofi.rasi" "$ROFI_COLORS"
    
    # Update Wallpaper
    if [ "$STR" == "dark" ]; then
        hyprctl hyprpaper preload "$HOME/.config/hypr/assets/Arch-Dark.png"
        hyprctl hyprpaper wallpaper ",$HOME/.config/hypr/assets/Arch-Dark.png"
    else
        hyprctl hyprpaper preload "$HOME/.config/hypr/assets/Arch-Light.png"
        hyprctl hyprpaper wallpaper ",$HOME/.config/hypr/assets/Arch-Light.png"
    fi
}

CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$CURRENT_SCHEME" == "'prefer-dark'" ]; then
    apply_theme "light"
else
    apply_theme "dark"
fi
