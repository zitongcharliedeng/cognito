#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Sync status bar state to match the current workspace's fullscreen state
# Any action in this OS, which possibly causes a current-workspace-fullscreen state change, should call this script!
# This is the single source of truth for status bar state detection

# Check if the current workspace has fullscreen/maximized windows and update status bar accordingly
if hyprctl activeworkspace | grep -q "hasfullscreen: 1" 2>/dev/null; then
    echo "Current workspace has fullscreen - retracting status bar space"
    _retract-status-bar-space
else
    echo "Current workspace is normal - reserving status bar space"
    _reserve-status-bar-space
fi
