#!/bin/sh
# Atomic close current window with status bar update
# Any action in this OS, which wants to cause a currently-focused window to close, should call this script and nothing else!
# This wrapper ensures the status bar reflects the fullscreen state after window closure

echo "Closing current window..."

# Close the current window in Hyprland
hyprctl dispatch closewindow

# Wait a moment for Hyprland to process the window closure
sleep 0.1

_sync-current-workspace-fullscreen-state
