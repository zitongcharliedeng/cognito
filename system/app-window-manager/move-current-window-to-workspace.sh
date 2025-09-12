#!/bin/sh
# Atomic move current window to workspace with status bar update
# Any action in this OS, which wants to move the currently-focused window to a different workspace, should call this script and nothing else!
# This wrapper ensures the status bar reflects the fullscreen state after window movement

if [ -z "$1" ]; then
    echo "Usage: move-current-window-to-workspace.sh <workspace_number>"
    echo "  workspace_number - The workspace to move the current window to (1-5)"
    exit 1
fi

WORKSPACE="$1"

echo "Moving current window to workspace $WORKSPACE..."

# Move the current window to the target workspace in Hyprland
hyprctl dispatch movetoworkspace "$WORKSPACE"

# Wait a moment for Hyprland to process the window movement
sleep 0.1

_sync-current-workspace-fullscreen-state
