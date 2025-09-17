#!/usr/bin/env bash
# Fuzzel additional commands (has app launching by default)

case "$1" in
  "lock-screen")
    swaylock
    ;;
  "screenshot")
    gnome-screenshot
    ;;
  "screenshot-area")
    gnome-screenshot -a
    ;;
  "maximize-window")
    # This would need Niri API integration
    echo "Maximize window (not yet implemented)"
    ;;
  "fullscreen-window")
    # This would need Niri API integration  
    echo "Fullscreen window (not yet implemented)"
    ;;
  "close-window")
    # This would need Niri API integration
    echo "Close window (not yet implemented)"
    ;;
  "workspace-1")
    # This would need Niri API integration
    echo "Switch to workspace 1 (not yet implemented)"
    ;;
  "workspace-2")
    echo "Switch to workspace 2 (not yet implemented)"
    ;;
  "workspace-3")
    echo "Switch to workspace 3 (not yet implemented)"
    ;;
  "workspace-4")
    echo "Switch to workspace 4 (not yet implemented)"
    ;;
  "workspace-5")
    echo "Switch to workspace 5 (not yet implemented)"
    ;;
  "workspace-6")
    echo "Switch to workspace 6 (not yet implemented)"
    ;;
  "workspace-7")
    echo "Switch to workspace 7 (not yet implemented)"
    ;;
  "workspace-8")
    echo "Switch to workspace 8 (not yet implemented)"
    ;;
  "workspace-9")
    echo "Switch to workspace 9 (not yet implemented)"
    ;;
  "workspace-10")
    echo "Switch to workspace 10 (not yet implemented)"
    ;;
  "workspace-overview")
    echo "Workspace overview (not yet implemented - Niri doesn't have built-in overview)"
    ;;
  *)
    echo "Available Fuzzel commands:"
    echo "  lock-screen - Lock the screen"
    echo "  screenshot - Take a screenshot"
    echo "  screenshot-area - Take a screenshot of selected area"
    echo "  maximize-window - Maximize current window"
    echo "  fullscreen-window - Toggle fullscreen for current window"
    echo "  close-window - Close current window"
    echo "  workspace-1 to workspace-10 - Switch to specific workspace"
    echo "  workspace-overview - Show workspace overview (not available in Niri)"
    ;;
esac
