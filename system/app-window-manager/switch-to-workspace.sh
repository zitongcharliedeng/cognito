#!/bin/sh
# Atomic workspace switch with status bar update
# Any action in this OS, which wants to cause a workspace switch, should call this script and nothing else!
# This wrapper ensures the status bar reflects the fullscreen state of the target workspace

if [ -z "$1" ]; then
    echo "Usage: switch-to-workspace.sh <workspace_number>"
    echo "  workspace_number - The workspace to switch to (1-5)"
    exit 1
fi

WORKSPACE="$1"

echo "Switching to workspace $WORKSPACE..."

# Switch to the workspace in Hyprland
hyprctl dispatch workspace "$WORKSPACE"

# Wait a moment for Hyprland to process the workspace change
sleep 0.1

_sync-current-workspace-fullscreen-state
