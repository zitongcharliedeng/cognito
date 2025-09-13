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
  # Also close workspace overview when closing omnibar
  niri msg action toggle-workspace-overview
  exit 0
fi

# Omnibar is not running - open it
echo "Omnibar is closed - opening it"
# Open workspace overview when opening omnibar
niri msg action toggle-workspace-overview

# Start a background process to monitor rofi and close workspace overview when rofi exits
(
  while pgrep rofi >/dev/null; do
    sleep 0.1
  done
  # Rofi has exited, close workspace overview
  niri msg action toggle-workspace-overview
) &

# Minimal inline overlay via rofi message (keeps config tiny and robust)
MESG="$(date '+%H:%M')  •  placeholder"

# Create menu items using printf directly (avoids Nix escaping issues)
# -i flag enables case-insensitive matching
choice=$(printf '%s\n' \
  "Apps" \
  "Open Terminal" \
  "--- Window Manipulation ---" \
  "Window Manipulation" \
  "--- System Controls ---" \
  "System Controls" \
  "--- Screenshots ---" \
  "Screenshots" | rofi-wayland -dmenu -i -p "$MESG" -theme-str 'window { width: 20%; } listview { lines: 6; }')

case "$choice" in
  "Apps")
    rofi-wayland -show drun -i -theme-str 'window { width: 20%; } listview { lines: 8; }'
    ;;
  "Open Terminal")
    kitty &
    ;;
  "Window Manipulation")
    # Show window manipulation commands in a rofi menu
    window_choice=$(printf '%s\n' \
      "Close Active Window" \
      "Toggle Fullscreen on Active Window" \
      "Switch to Workspace" \
      "Move Window to Workspace" | rofi-wayland -dmenu -i -p "Window Manipulation" -theme-str 'window { width: 20%; } listview { lines: 4; }')
    
    case "$window_choice" in
      "Close Active Window")
        close-current-window
        ;;
      "Toggle Fullscreen on Active Window")
        toggle-current-window-fullscreen
        ;;
      "Switch to Workspace")
        # Show input dialog for workspace number
        workspace_num=$(rofi-wayland -dmenu -i -p "Enter workspace number:" -theme-str 'window { width: 20%; }')
        if [ -n "$workspace_num" ] && [ "$workspace_num" -eq "$workspace_num" ] 2>/dev/null; then
          switch-to-workspace "$workspace_num"
        fi
        ;;
      "Move Window to Workspace")
        # Show input dialog for workspace number
        workspace_num=$(rofi-wayland -dmenu -i -p "Enter workspace number:" -theme-str 'window { width: 20%; }')
        if [ -n "$workspace_num" ] && [ "$workspace_num" -eq "$workspace_num" ] 2>/dev/null; then
          move-current-window-to-workspace "$workspace_num"
        fi
        ;;
    esac
    ;;
  "System Controls")
    # Show system control applications in a rofi menu
    system_choice=$(printf '%s\n' \
      "XFCE Settings" \
      "Audio Control (Pavucontrol)" \
      "Brightness Control" \
      "Display Manager (wlr-randr)" \
      "Display Profiles (Kanshi)" | rofi-wayland -dmenu -i -p "System Controls" -theme-str 'window { width: 20%; } listview { lines: 6; }')
    
    case "$system_choice" in
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
    esac
    ;;
  "Screenshots")
    # Show screenshot commands in a rofi menu
    screenshot_choice=$(printf '%s\n' \
      "Screenshot region (grim+slurp)" \
      "Screenshot full screen (grim)" \
      "Screenshot window (grim+slurp)" \
      "Screenshot output (grim)" | rofi-wayland -dmenu -i -p "Screenshots" -theme-str 'window { width: 20%; } listview { lines: 4; }')
    
    case "$screenshot_choice" in
      "Screenshot region (grim+slurp)")
        grim -g "$(slurp)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
        ;;
      "Screenshot full screen (grim)")
        grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png
        ;;
      "Screenshot window (grim+slurp)")
        grim -g "$(slurp -o)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
        ;;
      "Screenshot output (grim)")
        grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png
        ;;
    esac
    ;;
esac
