#!/bin/sh
# Status bar state refresher - handles both one-time updates and continuous monitoring

# Check if any workspace has maximized "fullscreen" windows (will show as an f[1] workspace state)
check_fullscreen() {
  hyprctl workspaces | grep -q "f[1]" 2>/dev/null
}

# Check if spotlight/rofi (omnibar view) is currently running
check_omnibar() {
  pgrep rofi >/dev/null 2>&1
}

# Note: We don't actually need monitor resolution for status bar state detection
# We only need to check workspace fullscreen state and rofi process status

update_status_bar_once() {
  # Only try to update variables if eww daemon is running and has windows open
  if ! pgrep eww >/dev/null 2>&1; then
    return 0  # Eww daemon not running, nothing to update
  fi
  
  # Check if eww has any windows open (variables only exist when windows are open)
  if ! eww list-windows | grep -q "window" 2>/dev/null; then
    return 0  # No windows open, variables don't exist yet
  fi

  # if check_fullscreen; then
  #   eww update collapse_status_bar=true 2>/dev/null || true
  # else
  #   eww update collapse_status_bar=false 2>/dev/null || true
  # fi

  # if check_omnibar; then
  #   eww update force_extend_status_bar=true 2>/dev/null || true
  # else
  #   eww update force_extend_status_bar=false 2>/dev/null || true
  # fi
}

# Check if we should run in monitor mode (continuous monitoring)
if [ "$1" = "--constantly-monitor-and-update" ]; then  # Currently don't use constant monitoring, not worth it and I can reset state with a simple omnibar toggle if any ephemeral event occurs
  # Initial status bar update
  update_status_bar_once

  # Optional lightweight polling every 10 seconds as safety net for missed events
  # Most updates should be event-driven:
  # - Omnibar open/close (META+SPACE) → triggers update
  # - Fullscreen toggle (META+F) → triggers update  
  # - Workspace switching (META+1,2,3,4,5) → triggers update
  # - This 10-second poll catches any missed events
  while true; do
    sleep 10
    update_status_bar_once
  done
elif [ "$1" = "--update-once" ] || [ -z "$1" ]; then
  update_status_bar_once
else
  # Invalid parameters
  echo "Usage: status-bar-state-refresher [--update-once|--constantly-monitor-and-update]"
  echo "  --update-once: Update status bar once and exit (default)"
  echo "  --constantly-monitor-and-update: Continuously monitor and update every second"
  exit 1
fi
