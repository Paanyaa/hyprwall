#!/bin/bash

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

Target_dir="$HOME/.hyprwall"
Clone_dir="$HOME/hyprwall"

echo -e "${CYAN}Starting Hyprwall uninstall...${NC}"

# Ask user which config layout to use
echo -e "${YELLOW}Select config layout:${NC}"
echo "1) UserConfigs (old installation)"
echo "2) System defaults (new installation)"
read -p "Enter choice [1/2]: " choice

if [[ "$choice" == "1" ]]; then
    STARTUP_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
    KEYBINDS_FILE="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
    echo -e "${GREEN}Using UserConfigs paths${NC}"
else
    STARTUP_FILE="$HOME/.config/hypr/configs/Startup_Apps.conf"
    KEYBINDS_FILE="$HOME/.config/hypr/config/Keybinds.conf"
    echo -e "${GREEN}Using System default paths${NC}"
fi

# Remove ~/.hyprwall directory
if [ -d "$Target_dir" ]; then
    rm -rf "$Target_dir"
    echo -e "${YELLOW}Removed $Target_dir${NC}"
fi

# Replace our live wallpaper startup line with direct mpvpaper call for minecraft.mp4 on eDP-2
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"
REPLACEMENT_LINE="exec-once = mpvpaper -o \"load-scripts=no no-audio --loop\" eDP-2 Videos/minecraft.mp4"

if grep -Fxq "$STARTUP_LINE" "$STARTUP_FILE"; then
    sed -i "s|$STARTUP_LINE|$REPLACEMENT_LINE|" "$STARTUP_FILE"
    echo -e "${GREEN}Replaced run_wallpaper.sh with direct mpvpaper startup line (on eDP-2)${NC}"
fi

# Remove the keybind line from Keybinds.conf
KEYBIND_LINE="bind = \$mainMod CTRL, W, exec, /usr/local/bin/toggle-live-wallpaper"
if grep -Fxq "$KEYBIND_LINE" "$KEYBINDS_FILE"; then
    sed -i "\|$KEYBIND_LINE|d" "$KEYBINDS_FILE"
    echo -e "${YELLOW}Removed toggle-live-wallpaper keybind${NC}"
fi

# Remove toggle-live-wallpaper from /usr/local/bin
if [ -f "/usr/local/bin/toggle-live-wallpaper" ]; then
    sudo rm /usr/local/bin/toggle-live-wallpaper
    echo -e "${YELLOW}Removed /usr/local/bin/toggle-live-wallpaper${NC}"
fi

# Remove cloned hyprwall repo directory from home to avoid residue
if [ -d "$Clone_dir" ]; then
    rm -rf "$Clone_dir"
    echo -e "${YELLOW}Removed cloned hyprwall directory from home${NC}"
fi

echo -e "${CYAN}--------------------------------------------------${NC}"
echo -e "${GREEN}Uninstall complete.${NC}"
echo -e "${CYAN}--------------------------------------------------${NC}"
echo -e "${YELLOW}Your system will now use:${NC}"
echo -e "${RED}$REPLACEMENT_LINE${NC}"
echo -e "to keep minecraft.mp4 running as wallpaper even after uninstall."
echo -e "${CYAN}--------------------------------------------------${NC}"

# Ask user if they want to reboot
read -p "Do you want to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    echo -e "${RED}Rebooting system...${NC}"
    sudo reboot
else
    echo -e "${GREEN}You can reboot later to apply changes.${NC}"
fi

