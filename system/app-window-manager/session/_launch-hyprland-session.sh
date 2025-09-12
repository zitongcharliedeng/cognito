#!/bin/sh
#
# NAMING CONVENTION: Scripts prefixed with "_" are private helper functions
# that should only be called by other user-action scripts (like switch-workspace, 
# toggle-fullscreen, etc.). These helpers will never appear in omnibar menus, 
# like the other user-action wrapper scripts.
#
# Launch Hyprland session with VM-safe renderer selection
# In VMs, virgl/virtio 3D can stall wlroots compositors (random freezes).
# Use pixman only when virtualized; keep GPU acceleration on bare metal.

CONFIG_PATH=/etc/hypr/hyprland.conf

# Optional per-user override: ~/.config/cognito/renderer (pixman|gl)
OVERRIDE="$HOME/.config/cognito/renderer"
if [ -f "$OVERRIDE" ]; then
  R=$(cat "$OVERRIDE" | tr -d '\n' )
  if [ "$R" = "pixman" ] || [ "$R" = "gl" ]; then
    export WLR_RENDERER="$R"
  fi
else
  if systemd-detect-virt --quiet; then
    export WLR_RENDERER=pixman
  fi
fi

exec Hyprland -c "$CONFIG_PATH"
