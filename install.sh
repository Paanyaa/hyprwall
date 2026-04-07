#!/bin/bash

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

Target_dir="$HOME/.hyprwall"
Wallpaper_dir="$HOME/Videos/wallpapers"
Clone_dir="$HOME/hyprwall"

echo -e "${CYAN}Starting Hyprwall installation...${NC}"

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

# Clean old ~/.hyprwall
[ -d "$Target_dir" ] && rm -rf "$Target_dir" && echo -e "${YELLOW}Removed old $Target_dir${NC}"
mkdir -p "$Target_dir"

# Ensure wallpapers directory exists
[ ! -d "$Wallpaper_dir" ] && mkdir -p "$Wallpaper_dir" && echo -e "${YELLOW}Created $Wallpaper_dir${NC}"

# Default wallpaper state file
echo "minecraft.mp4" > "$Target_dir/Wallpaper_Dir.txt"
echo -e "${GREEN}Default wallpaper set to minecraft.mp4${NC}"

# Copy run_wallpaper.sh into ~/.hyprwall
cp run_wallpaper.sh "$Target_dir/"
chmod +x "$Target_dir/run_wallpaper.sh"
echo -e "${GREEN}Installed run_wallpaper.sh${NC}"

# Install toggle-live-wallpaper globally
sudo cp toggle-live-wallpaper /usr/local/bin/toggle-live-wallpaper
sudo chmod +x /usr/local/bin/toggle-live-wallpaper
echo -e "${GREEN}Installed toggle-live-wallpaper globally${NC}"

# Handle live wallpaper section
LIVE_SECTION="# live wallpaper stuff"
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"

if grep -Fxq "$LIVE_SECTION" "$STARTUP_FILE"; then
    sed -i "/$LIVE_SECTION/,+1c\\$LIVE_SECTION\n$STARTUP_LINE" "$STARTUP_FILE"
    echo -e "${YELLOW}Replaced existing live wallpaper section with new startup line${NC}"
else
    echo -e "\n$LIVE_SECTION\n$STARTUP_LINE" >> "$STARTUP_FILE"
    echo -e "${GREEN}Created live wallpaper section and added startup line${NC}"
fi

# Add keybind section with marker
KEYBIND_SECTION="# live-wallpaper-keybinding"
KEYBIND_LINE='bind = $mainMod CTRL, W, exec, /usr/local/bin/toggle-live-wallpaper'

if grep -Fxq "$KEYBIND_SECTION" "$KEYBINDS_FILE"; then
    sed -i "/$KEYBIND_SECTION/,+1c\\$KEYBIND_SECTION\n$KEYBIND_LINE" "$KEYBINDS_FILE"
    echo -e "${YELLOW}Updated live-wallpaper keybinding section${NC}"
else
    echo -e "\n$KEYBIND_SECTION\n$KEYBIND_LINE" >> "$KEYBINDS_FILE"
    echo -e "${GREEN}Created live-wallpaper keybinding section${NC}"
fi

# Copy minecraft.mp4 into wallpapers directory if present
if [ -f "minecraft.mp4" ]; then
    cp minecraft.mp4 "$Wallpaper_dir/"
    echo -e "${GREEN}Copied minecraft.mp4 into $Wallpaper_dir${NC}"
fi

# Remove cloned hyprwall repo directory from home to avoid residue
if [ -d "$Clone_dir" ]; then
    rm -rf "$Clone_dir"
    echo -e "${YELLOW}Removed cloned hyprwall directory from home${NC}"
fi

echo -e "${CYAN}--------------------------------------------------${NC}"
echo -e "${GREEN}Install complete.${NC}"
echo -e "${CYAN}--------------------------------------------------${NC}"
echo -e "${YELLOW}IMPORTANT:${NC} The upstream '### wallpaper stuff ###' section is still active."
echo -e "To prevent conflicts, you should comment out those lines."
echo -e "${CYAN}A new Kitty terminal will now open with Startup_Apps.conf so you can edit it.${NC}"
echo -e "Use ${RED}Ctrl+S${NC} to save and ${RED}Ctrl+X${NC} to exit Nano."
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

