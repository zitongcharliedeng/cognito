#!/bin/sh
# Atomic fullscreen toggle
# Any action in this OS, which wants to cause a toggle in fullscreen, should call this script and nothing else!

echo "Toggling fullscreen..."

# Command to toggle fullscreen in Niri
niri msg action toggle-fullscreen
