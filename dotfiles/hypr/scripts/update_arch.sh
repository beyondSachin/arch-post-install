#!/bin/bash
# Update Arch — Full system update with styled terminal output

echo ""
echo -e "\033[1;34m   ╭───────────────────────────────────╮\033[0m"
echo -e "\033[1;34m   │\033[1;36m      󰣇  Arch Linux Update         \033[1;34m│\033[0m"
echo -e "\033[1;34m   ╰───────────────────────────────────╯\033[0m"
echo ""

echo -e "\033[1;33m   ⏳ Synchronizing package databases...\033[0m"
echo ""

# Run the update
if sudo pacman -Syu --noconfirm; then
    echo ""
    echo -e "\033[1;32m   ✅ System updated successfully!\033[0m"
    notify-send "System Update" "Arch Linux updated successfully!" -i software-update-available-symbolic
else
    echo ""
    echo -e "\033[1;31m   ❌ Update failed. Check output above.\033[0m"
    notify-send "System Update" "Update failed — check terminal for details." -i dialog-error-symbolic -u critical
fi

echo ""
read -r -p "   Press Enter to close..."
