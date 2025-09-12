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
# Only remove top gap, preserve existing gap settings
hyprctl keyword workspace "1,gapsin:0"
