#!/usr/bin/env bash
#
# Name: _tty-return-hint.sh
# Purpose: Print a clear hint on text consoles about returning to the main KDE session (tty1),
#          then automatically switch back to tty1 after a short delay.
# Usage: Run as a oneshot systemd service after the display manager (graphical session) is up.
# Notes:
#   - This script assumes the KDE session runs on tty1.
#   - It prints to common text VTs and then uses chvt to return after 5 seconds.

set -euo pipefail

TARGET_VT=1
DELAY_SECONDS=5

MESSAGE="KDE session is running on tty${TARGET_VT}. Press Ctrl+Alt+F${TARGET_VT} to return. Auto-returning in ${DELAY_SECONDS}s..."

# Print hint to a few common text VTs so the user sees it where logs appear
for t in /dev/tty2 /dev/tty3 /dev/tty4 /dev/tty5 /dev/tty6; do
  if [ -w "$t" ]; then
    {
      echo
      echo "============================================================"
      echo "$MESSAGE"
      echo "============================================================"
      echo
    } > "$t" || true
  fi
done

sleep "$DELAY_SECONDS"

# Switch back to the main graphical VT
if command -v chvt >/dev/null 2>&1; then
  chvt "$TARGET_VT" || true
else
  /run/current-system/sw/bin/chvt "$TARGET_VT" || true
fi


