#!/bin/bash

Target_dir="$HOME/.hyprwall"
Wallpaper_dir="$HOME/Videos/wallpapers"
STARTUP_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
KEYBINDS_FILE="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
Clone_dir="$HOME/hyprwall"

# Always start fresh: remove old hyprwall directory
[ -d "$Target_dir" ] && rm -rf "$Target_dir" && echo "Removed old $Target_dir"
mkdir -p "$Target_dir"

# Ensure wallpapers directory exists
[ ! -d "$Wallpaper_dir" ] && mkdir -p "$Wallpaper_dir" && echo "Created $Wallpaper_dir"

# Default wallpaper state file
echo "glitch_girl.mp4" > "$Target_dir/Wallpaper_Dir.txt"

# Copy run_wallpaper.sh into ~/.hyprwall
cp run_wallpaper.sh "$Target_dir/"
chmod +x "$Target_dir/run_wallpaper.sh"

# Install toggle-live-wallpaper globally
sudo cp toggle-live-wallpaper /usr/local/bin/toggle-live-wallpaper
sudo chmod +x /usr/local/bin/toggle-live-wallpaper

# Comment out old wallpaper stuff
sed -i '/# wallpaper stuff/,/^[[:space:]]*$/ s/^[^#]/#&/' "$STARTUP_FILE"

# Add run_wallpaper.sh startup line
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"
if ! grep -Fxq "$STARTUP_LINE" "$STARTUP_FILE"; then
    sed -i "/# wallpaper stuff/a $STARTUP_LINE" "$STARTUP_FILE"
    echo "Added run_wallpaper.sh under # wallpaper stuff"
fi

# Add keybind for toggle-live-wallpaper
KEYBIND_LINE="bind = \$mainMod CTRL, W, exec, /usr/local/bin/toggle-live-wallpaper"
if ! grep -Fxq "$KEYBIND_LINE" "$KEYBINDS_FILE"; then
    echo "$KEYBIND_LINE" >> "$KEYBINDS_FILE"
    echo "Added toggle-live-wallpaper keybind"
fi

# Move minecraft.mp4 into wallpapers directory if present
if [ -f "minecraft.mp4" ]; then
    cp minecraft.mp4 "$Wallpaper_dir/"
    echo "Copied minecraft.mp4 into $Wallpaper_dir"
fi

# Remove cloned hyprwall repo directory from home to avoid residue
if [ -d "$Clone_dir" ]; then
    rm -rf "$Clone_dir"
    echo "Removed cloned hyprwall directory from home"
fi

echo "Install complete."

