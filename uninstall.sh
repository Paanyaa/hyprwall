#!/bin/bash

Target_dir="$HOME/.hyprwall"
STARTUP_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
KEYBINDS_FILE="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
Clone_dir="$HOME/hyprwall"

# Remove ~/.hyprwall directory
if [ -d "$Target_dir" ]; then
    rm -rf "$Target_dir"
    echo "Removed $Target_dir"
fi

# Remove the exec-once line from Startup_Apps.conf
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"
if grep -Fxq "$STARTUP_LINE" "$STARTUP_FILE"; then
    sed -i "\|$STARTUP_LINE|d" "$STARTUP_FILE"
    echo "Removed run_wallpaper.sh startup line"
fi

# Remove the keybind line from UserKeybinds.conf
KEYBIND_LINE="bind = \$mainMod CTRL, W, exec, /usr/local/bin/toggle-live-wallpaper"
if grep -Fxq "$KEYBIND_LINE" "$KEYBINDS_FILE"; then
    sed -i "\|$KEYBIND_LINE|d" "$KEYBINDS_FILE"
    echo "Removed toggle-live-wallpaper keybind"
fi

# Remove toggle-live-wallpaper from /usr/local/bin
if [ -f "/usr/local/bin/toggle-live-wallpaper" ]; then
    sudo rm /usr/local/bin/toggle-live-wallpaper
    echo "Removed /usr/local/bin/toggle-live-wallpaper"
fi

# Remove cloned hyprwall repo directory from home to avoid residue
if [ -d "$Clone_dir" ]; then
    rm -rf "$Clone_dir"
    echo "Removed cloned hyprwall directory from home"
fi

echo "Uninstall complete."

