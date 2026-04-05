#!/bin/bash

# check if .hyprwall present
Target_dir="$HOME/.hyprwall"
if [ ! -d "$Target_dir" ]; then
    mkdir -p "$Target_dir"
    echo "Created $Target_dir"
fi

# check if wallpaper directory present in ~/Videos
Wallpaper_dir="$HOME/Videos/wallpapers"
if [ ! -d "$Wallpaper_dir" ]; then
    mkdir -p "$Wallpaper_dir"
    echo "Created $Wallpaper_dir"
fi

# file to save current wallpaper (default filename only)
echo "glitch_girl.mp4" > "$HOME/.hyprwall/Wallpaper_Dir.txt"

# copy run_wallpaper.sh into ~/.hyprwall
cp run_wallpaper.sh "$Target_dir/"
chmod +x "$Target_dir/run_wallpaper.sh"

# install toggle-live-wallpaper globally
sudo cp toggle-live-wallpaper /usr/local/bin/toggle-live-wallpaper
sudo chmod +x /usr/local/bin/toggle-live-wallpaper

# path to Startup_Apps.conf
STARTUP_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
STARTUP_LINE="exec-once = $HOME/.hyprwall/run_wallpaper.sh"

# 1. Comment out all non-comment lines in the "# wallpaper stuff" section
sed -i '/# wallpaper stuff/,/^[[:space:]]*$/ s/^[^#]/#&/' "$STARTUP_FILE"

# 2. Add our exec-once line right under "# wallpaper stuff" if not already present
if ! grep -Fxq "$STARTUP_LINE" "$STARTUP_FILE"; then
    sed -i "/# wallpaper stuff/a $STARTUP_LINE" "$STARTUP_FILE"
    echo "Added run_wallpaper.sh under # wallpaper stuff"
else
    echo "Startup line already present"
fi

