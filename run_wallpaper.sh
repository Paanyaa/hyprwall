#!/bin/bash
MONITOR="eDP-2"
WALLPAPER_DIR="$HOME/Videos/wallpapers"
STATE_FILE="$HOME/.hyprwall/Wallpaper_Dir.txt"

if [ -f "$STATE_FILE" ]; then
    FILE=$(cat "$STATE_FILE")
    WALL="$WALLPAPER_DIR/$FILE"
    if [ -n "$FILE" ] && [ -f "$WALL" ]; then
        exec mpvpaper -o "no-audio --loop" "$MONITOR" "$WALL"
    else
        echo "Wallpaper file invalid or missing: $WALL"
        exit 1
    fi
else
    echo "No state file found at $STATE_FILE"
    exit 1
fi

