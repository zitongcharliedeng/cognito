#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Launch the dropdown status bar with proper daemon management and error handling
# This script ensures clean startup by killing existing processes and waiting for proper initialization

# Kill any existing eww processes
pkill eww 2>/dev/null || true
sleep 1

# Start daemon in background
eww daemon &
# Wait for daemon to be ready, then open both windows
sleep 5

# Open windows with error handling
eww open dropdown_status_bar_appearance || echo "Failed to open appearance window"
sleep 1
eww open dropdown_status_bar_hitbox_normal || echo "Failed to open hitbox window" 

echo "EWW dropdown status bar launch completed"
