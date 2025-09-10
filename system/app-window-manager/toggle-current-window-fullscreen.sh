#!/bin/sh
# Atomic fullscreen toggle with status bar update
# Any action in this OS, which wants to cause a toggle in fullscreen, should call this script and nothing else!
# This wrapper ensures fullscreen state and status bar are always in sync

echo "Toggling fullscreen..."

# Command to toggle fullscreen in Hyprland
hyprctl dispatch fullscreen

# Wait a moment for Hyprland to process the fullscreen change
sleep 0.1

_sync-current-workspace-fullscreen-state
