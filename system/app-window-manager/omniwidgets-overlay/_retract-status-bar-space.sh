#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Remove status bar space reservation (for fullscreen/collapsed mode)
# This restores normal workspace gaps when status bar should not take up space

# Remove status bar top gap, restore to normal gaps from hyprland.conf
# Use gapsout to remove space at screen edges, not gapsin which affects window spacing
# Apply to all workspaces (remove workspace number to affect all)
# DEBUG: Disabled gap manipulation - HyprPanel should handle space reservation
# hyprctl keyword workspace "gapsout:2"
