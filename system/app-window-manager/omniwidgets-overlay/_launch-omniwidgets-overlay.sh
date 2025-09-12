#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Launch omniwidgets overlay (HyprPanel) with proper space reservation
# This script ensures clean startup and reserves appropriate screen space

# Create hyprpanel config directory
mkdir -p ~/.config/ags

# Launch HyprPanel using the nixpkgs package
hyprpanel &

# Reserve space for status bar after panel initializes
sleep 2  # Wait for panel to be ready
_reserve-status-bar-space
