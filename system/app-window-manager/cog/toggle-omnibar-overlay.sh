#!/bin/sh
#
# NAMING CONVENTION: Scripts without "_" prefix are public user actions
# that can be called directly by users or other scripts. These appear in
# omnibar menus and are the main interface for user interactions.
#
# Toggle the cognito omnibar overlay - the primary way to access any action in Cognito OS.
# This script will open the omnibar if it's closed, or close it if it's already open.
# This is the central command interface that provides fuzzy-finding access to all
# system functions, applications, and utilities without needing to memorize shortcuts.
#
# The omnibar follows the "Brain as Interface" principle - it should be intuitive
# enough that even someone with amnesia could navigate the system using only
# English language understanding.

# Check if rofi is already running and close it
if pgrep rofi >/dev/null; then
  echo "Omnibar is open - closing it"
  pkill rofi
  exit 0
fi

# Omnibar is not running - open it
echo "Omnibar is closed - opening it"

# Minimal inline overlay via rofi message (keeps config tiny and robust)
MESG="$(date '+%H:%M')  •  placeholder"

# Create menu items using printf directly (avoids Nix escaping issues)
# -i flag enables case-insensitive matching
choice=$(printf '%s\n' \
  "Apps" \
  "Open Terminal" \
  "Close Active Window" \
  "Toggle Fullscreen on Active Window" \
  "Switch to Workspace 1" \
  "Switch to Workspace 2" \
  "Switch to Workspace 3" \
  "Switch to Workspace 4" \
  "Switch to Workspace 5" \
  "Exit Hyprland" \
  "--- System Controls ---" \
  "XFCE Settings" \
  "Audio Control (Pavucontrol)" \
  "Brightness Control" \
  "Display Manager (wlr-randr)" \
  "Display Profiles (Kanshi)" \
  "--- Screenshots ---" \
  "Screenshot region (grim+slurp)" \
  "Screenshot full screen (grim)" \
  "Screenshot region (hyprshot)" \
  "Screenshot window (hyprshot)" \
  "Screenshot output (hyprshot)" \
  "--- Debug ---" \
  "[Debug] Force renderer: pixman" \
  "[Debug] Force renderer: gl" \
  "[Debug] Remove renderer override" \
  "[Debug] Show renderer status" | rofi -dmenu -i -p "$MESG" -theme-str 'window { width: 20%; } listview { lines: 18; }')

case "$choice" in
  "Apps")
    rofi -show drun -i -theme-str 'window { width: 20%; } listview { lines: 8; }'
    ;;
  "Open Terminal")
    kitty &
    ;;
  "Close Active Window")
    close-current-window
    ;;
  "Toggle Fullscreen on Active Window")
    toggle-current-window-fullscreen
    ;;
  "Switch to Workspace 1")
    switch-to-workspace 1
    ;;
  "Switch to Workspace 2")
    switch-to-workspace 2
    ;;
  "Switch to Workspace 3")
    switch-to-workspace 3
    ;;
  "Switch to Workspace 4")
    switch-to-workspace 4
    ;;
  "Switch to Workspace 5")
    switch-to-workspace 5
    ;;
  "Exit Hyprland")
    hyprctl dispatch exit
    ;;
  "Screenshot region (grim+slurp)")
    grim -g "$(slurp)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
    ;;
  "Screenshot full screen (grim)")
    grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png
    ;;
  "Screenshot region (hyprshot)")
    hyprshot -m region
    ;;
  "Screenshot window (hyprshot)")
    hyprshot -m window
    ;;
  "Screenshot output (hyprshot)")
    hyprshot -m output
    ;;
  "XFCE Settings")
    xfce4-settings &
    ;;
  "Audio Control (Pavucontrol)")
    pavucontrol &
    ;;
  "Brightness Control")
    kitty -e brightnessctl --help &
    ;;
  "Display Manager (wlr-randr)")
    kitty -e wlr-randr --help &
    ;;
  "Display Profiles (Kanshi)")
    kitty -e kanshi --help &
    ;;
  "[Debug] Force renderer: pixman")
    hyprctl keyword renderer:pixman
    ;;
  "[Debug] Force renderer: gl")
    hyprctl keyword renderer:gl
    ;;
  "[Debug] Remove renderer override")
    hyprctl keyword renderer:auto
    ;;
  "[Debug] Show renderer status")
    hyprctl keyword renderer:auto
    ;;
  *[0-9]*)
    NUM=$(echo "$choice" | grep -o '[0-9]\+')
    if [ -n "$NUM" ]; then
      move-current-window-to-workspace "$NUM"
    fi
    ;;
esac
