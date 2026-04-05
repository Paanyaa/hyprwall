#!/bin/bash

#check if .hyprwall present.....
Target_dir="$HOME/.hyprwall"
if [ ! -d "$Target_dir" ]; then
	mkdir -p "$Target_dir"
	echo "Created $Target_dir"
fi

#check if wallpaper directory persent in ~/Videos
Wallpaper_dir="$HOME/Videos/wallpapers"
if [ ! -d "$Wallpaper_dir" ]; then
	mkdir -p "$Wallpaper_dir"
	echo "Created $Wallpaper_dir"
fi

#file to save current wallpaper
cat <<EOF > "$HOME/.hyprwall/Wallpaper_Dir.txt"
$HOME/Vidoes/wallpapers/glitch_girl.mp4
EOF

sed -i '/# wallpaper stuff/,/^[[:space:]]*$/ s/^[^#]/#&/' $HOME/.config/hypr/UserConfigs/Startup_Apps.conf

sed -i "/# wallpaper stuff/,/^[[:space:]]*$/ {/^[[:space:]]*$/ i exec-once = mpvpaper -o \"no-audio --loop\" eDP-2 \$(cat \$HOME/.hyprwall/Wallpaper_Dir.txt)
}" "$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"



