{ config, pkgs, ... }:

let
  # Get the directory containing this file
  Omnibar_Dir = toString ./.;
in

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "cognito-omnibar" ''
      #!/bin/sh
      # Check if rofi is already running and close it
      if pgrep rofi >/dev/null; then
        pkill rofi
        # Update status bar state after closing rofi
        /etc/profiles/per-user/${config.systemUsername}/bin/status-bar-state-refresher 2>/dev/null || true
        exit 0
      fi

      # Update status bar state before opening rofi
      /etc/profiles/per-user/${config.systemUsername}/bin/status-bar-state-refresher 2>/dev/null || true

      # Minimal inline overlay via rofi message (keeps config tiny and robust)
      MESG="$(date '+%H:%M')  •  placeholder"

      # Create menu items using printf directly (avoids Nix escaping issues)
      choice=$(printf '%s\n' \
        "Apps" \
        "Open Terminal" \
        "Close Active Window" \
        "Toggle Fullscreen on Active Window" \
        "Switch to Workspace 1" \
        "Switch to Workspace 2" \
        "Switch to Workspace 3" \
        "Switch to Workspace 4" \
        "Switch to Workspace 5" \
        "Exit Hyprland" \
        "Screenshot region (grim+slurp)" \
        "Screenshot full screen (grim)" \
        "[Debug] Force renderer: pixman" \
        "[Debug] Force renderer: gl" \
        "[Debug] Remove renderer override" \
        "[Debug] Show renderer status" | rofi -dmenu -p "$MESG" -theme-str 'window { width: 20%; } listview { lines: 12; }')

      case "$choice" in
        "Apps")
          rofi -show drun -theme-str 'window { width: 20%; } listview { lines: 8; }'
          ;;
        "Open Terminal")
          kitty &
          ;;
        "Close Active Window")
          close-current-window
          ;;
        "Toggle Fullscreen on Active Window")
          toggle-current-window-fullscreen
          ;;
        "Switch to Workspace 1")
          switch-to-workspace 1
          ;;
        "Switch to Workspace 2")
          switch-to-workspace 2
          ;;
        "Switch to Workspace 3")
          switch-to-workspace 3
          ;;
        "Switch to Workspace 4")
          switch-to-workspace 4
          ;;
        "Switch to Workspace 5")
          switch-to-workspace 5
          ;;
        "Exit Hyprland")
          hyprctl dispatch exit
          ;;
        "Screenshot region (grim+slurp)")
          grim -g "$(slurp)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
          ;;
        "Screenshot full screen (grim)")
          grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png
          ;;
        "[Debug] Force renderer: pixman")
          hyprctl keyword renderer:pixman
          ;;
        "[Debug] Force renderer: gl")
          hyprctl keyword renderer:gl
          ;;
        "[Debug] Remove renderer override")
          hyprctl keyword renderer:auto
          ;;
        "[Debug] Show renderer status")
          hyprctl keyword renderer:auto
          ;;
        *[0-9]*)
          NUM=$(echo "$choice" | grep -o '[0-9]\+')
          if [ -n "$NUM" ]; then
            move-current-window-to-workspace "$NUM"
          fi
          ;;
      esac
    '')
  ];
}