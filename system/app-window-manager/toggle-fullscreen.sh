#!/bin/sh
# Atomic fullscreen toggle with status bar update
# This wrapper ensures fullscreen state and status bar are always in sync
# Any action I want to toggle in fullscreen should call this script and nothing else.

echo "Toggling fullscreen..."

# Toggle fullscreen in Hyprland
hyprctl dispatch fullscreen

# Wait a moment for Hyprland to process the fullscreen change
sleep 0.1

# Check the new fullscreen state and update status bar accordingly
if hyprctl workspaces | grep -q "f\[1\]" 2>/dev/null; then
    # Now in fullscreen mode
    echo "Entered fullscreen - collapsing status bar"
    set-fullscreen enter
else
    # Exited fullscreen mode
    echo "Exited fullscreen - restoring status bar"
    set-fullscreen exit
fi
