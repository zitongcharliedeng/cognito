#!/bin/sh
#
# Set the base status bar mode (collapsed or normal)
# This sets the "memory" state that persists across fullscreen transitions
# 
# Usage: set-base-bar-mode <collapsed|normal>

if [ $# -ne 1 ]; then
    echo "Usage: set-base-bar-mode <collapsed|normal>"
    echo "  collapsed - Hide the status bar (minimal footprint)"
    echo "  normal    - Show the status bar normally"
    exit 1
fi

MODE="$1"

# Validate mode parameter
case "$MODE" in
    collapsed|normal)
        echo "Setting baseBarMode to: $MODE"
        eww update baseBarMode="$MODE"
        
        # Update hitbox window accordingly
        if [ "$MODE" = "collapsed" ]; then
            echo "Removing status bar reserved space"
            eww close dropdown_status_bar_hitbox_normal 2>/dev/null || true
        else
            echo "Reserving status bar space"
            eww open dropdown_status_bar_hitbox_normal 2>/dev/null || true
        fi
        ;;
    *)
        echo "Error: Invalid mode '$MODE'"
        echo "Valid modes are: collapsed, normal"
        exit 1
        ;;
esac