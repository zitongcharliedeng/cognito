#!/bin/sh

# Any action in this OS, which results in a current-workspace-fullscreen state change, should call this script and nothing else!
# Sync status bar state to match the current workspace's fullscreen state

# Check if the current workspace has fullscreen/maximized windows and update status bar accordingly
if hyprctl activeworkspace | grep -q "f\[1\]" 2>/dev/null; then
    # Current workspace has fullscreen windows
    echo "Current workspace has fullscreen - collapsing status bar"
    eww update baseBarMode=collapsed
    eww close dropdown_status_bar_hitbox_normal 2>/dev/null || true
else
    # Current workspace has no fullscreen windows  
    echo "Current workspace is normal - showing status bar"
    eww update baseBarMode=normal
    # Open hitbox if not already open
    if ! eww list-windows | grep -q "dropdown_status_bar_hitbox_normal" 2>/dev/null; then
        eww open dropdown_status_bar_hitbox_normal
    fi
fi
