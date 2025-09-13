#!/bin/sh
# Atomic workspace switch
# Any action in this OS, which wants to cause a workspace switch, should call this script and nothing else!

if [ -z "$1" ]; then
    echo "Usage: switch-to-workspace.sh <workspace_number>"
    echo "  workspace_number - The workspace to switch to (1-5)"
    exit 1
fi

WORKSPACE="$1"

echo "Switching to workspace $WORKSPACE..."

# Switch to the workspace in Hyprland
hyprctl dispatch workspace "$WORKSPACE"
