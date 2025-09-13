#!/bin/sh
# Atomic close current window
# Any action in this OS, which wants to cause a currently-focused window to close, should call this script and nothing else!

echo "Closing current window..."

# Close the current window in Hyprland
hyprctl dispatch closewindow
