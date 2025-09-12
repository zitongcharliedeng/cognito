#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Remove status bar space reservation (for fullscreen/collapsed mode)
# This restores normal workspace gaps when status bar should not take up space

# Restore normal gaps without status bar reservation
hyprctl keyword workspace "1,gapsin:2,gapsout:2"
