#!/bin/bash

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

Target_dir="$HOME/.hyprwall"
Clone_dir="$HOME/hyprwall"

echo -e "${CYAN}Starting Hyprwall uninstall...${NC}"

# Ask user which config layout to use
echo -e "${YELLOW}Select config layout:${NC}"
echo "1) Old installation (UserConfigs)"
echo "2) Custom path (type manually)"
read -p "Enter choice [1/2]: " choice

if [[ "$choice" == "1" ]]; then
    STARTUP_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
    KEYBINDS_FILE="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
    echo -e "${GREEN}Using UserConfigs paths${NC}"
else
    read -p "Enter full path for Startup_Apps.conf: " STARTUP_FILE
    read -p "Enter full path for Keybinds.conf: " KEYBINDS_FILE
    echo -e "${GREEN}Using custom paths:${NC}"
    echo "Startup apps → $STARTUP_FILE"
    echo "Keybinds     → $KEYBINDS_FILE"
fi

# Remove ~/.hyprwall directory
if [ -d "$Target_dir" ]; then
    rm -rf "$Target_dir"
    echo -e "${YELLOW}Removed $Target_dir${NC}"
fi

# Replace live wallpaper startup line with direct mpvpaper call
LIVE_SECTION="# live wallpaper stuff"
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"
REPLACEMENT_LINE="exec-once = mpvpaper -o \"load-scripts=no no-audio --loop\" eDP-2 Videos/minecraft.mp4"

if grep -Fxq "$STARTUP_LINE" "$STARTUP_FILE"; then
    sed -i "s|$STARTUP_LINE|$REPLACEMENT_LINE|" "$STARTUP_FILE"
    echo -e "${GREEN}Replaced run_wallpaper.sh with direct mpvpaper startup line${NC}"
fi

# Remove live-wallpaper keybinding section
KEYBIND_SECTION="# live-wallpaper-keybinding"
if grep -Fxq "$KEYBIND_SECTION" "$KEYBINDS_FILE"; then
    sed -i "/$KEYBIND_SECTION/,+1d" "$KEYBINDS_FILE"
    echo -e "${YELLOW}Removed live-wallpaper keybinding section${NC}"
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

# Ask user if they want to open Startup_Apps.conf
read -p "Do you want to open Startup_Apps.conf for editing now? (Y/n): " edit_choice
edit_choice=${edit_choice:-Y}   # Default to Y if empty
if [[ "$edit_choice" == "y" || "$edit_choice" == "Y" ]]; then
    echo -e "${CYAN}Opening Startup_Apps.conf in Kitty + Nano...${NC}"
    echo -e "Use ${RED}Ctrl+S${NC} to save and ${RED}Ctrl+X${NC} to exit Nano."
    kitty -e bash -c "cd $(dirname "$STARTUP_FILE") && nano $(basename "$STARTUP_FILE")"
else
    echo -e "${YELLOW}Skipped opening Startup_Apps.conf${NC}"
fi

# Ask user if they want to reboot
read -p "Do you want to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    echo -e "${RED}Rebooting system...${NC}"
    sudo reboot
else
    echo -e "${GREEN}You can reboot later to apply changes.${NC}"
fi

