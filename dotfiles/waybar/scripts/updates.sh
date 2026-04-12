#!/bin/bash

# Fetch updates using user specified commands
arch_updates=$(checkupdates 2>/dev/null | wc -l || echo 0)
aur_updates=$(yay -Qua 2>/dev/null | wc -l || echo 0)

total=$((arch_updates + aur_updates))

# Status class for styling
if [ "$total" -gt 0 ]; then
    class="pending"
else
    class="updated"
fi

# Format: ArchCount|AurCount as requested
text="$arch_updates|$aur_updates"

printf '{"text": "%s", "tooltip": "Arch: %s\\nAUR: %s\\nTotal: %s updates", "class": "%s"}\n' \
    "$text" "$arch_updates" "$aur_updates" "$total" "$class"
