# This file is now a stub. 
# Prompt colors are dynamically managed by Catppuccin theme files in ~/.config/fish/themes/
# and switched in ~/.config/fish/conf.d/theme.fish based on system color scheme.

# Default fallbacks if theme files are missing
if not set -q fish_prompt_color_logo
    set -g fish_prompt_color_logo cyan
    set -g fish_prompt_color_time yellow
    set -g fish_prompt_color_user green
    set -g fish_prompt_color_cwd blue
    set -g fish_prompt_color_git magenta
    set -g fish_prompt_color_symbol orange
end
