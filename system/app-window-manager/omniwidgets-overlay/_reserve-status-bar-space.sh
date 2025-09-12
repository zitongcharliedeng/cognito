#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Reserve space at top of screen for status bar
# AGS/HyprPanel cannot programmatically reserve Wayland layer space.
# so we use Hyprland workspace rules to create artificial top gaps for the status bar

# Reserve 52px at top for status bar (adjust as needed for your panel height)
# Only add top gap, preserve existing gap settings from hyprland.conf
hyprctl keyword workspace "1,gapsin:52"
