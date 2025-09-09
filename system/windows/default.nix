{ config, pkgs, ... }:
{
  imports = [ ./steam/default.nix ];
  
  # TODO add vm tools to develop NixOS in NixOS or figure out the dry-run NixOS changes with failsafe of rebooting without saving the changes to git. Dry running switch command i think it is called - add this action to the omnibar, with a NixOS icon. Same with the other common NixOS commands.
  environment.systemPackages = with pkgs; [
    hyprpaper rofi-wayland jq eww
    obs-studio mangohud protonup
    wl-clipboard grim slurp
    kitty xfce.thunar firefox gnome-control-center libnotify alsa-utils brightnessctl papirus-icon-theme
    git htop

    (pkgs.writeShellScriptBin "cognito-omnibar" ''
    #!/bin/sh
    # Check if rofi is already running and close it
    if pgrep rofi >/dev/null; then
      pkill rofi
      exit 0
    fi

    # Minimal inline overlay via rofi message (keeps config tiny and robust)
    MESG="$(date '+%H:%M')  •  placeholder"

    menu="Apps\nOpen Terminal\nClose Active Window\nToggle Fullscreen on Active Window\nExit Hyprland\nScreenshot region (grim+slurp)\nScreenshot full screen (grim)\n[Debug] Force renderer: pixman\n[Debug] Force renderer: gl\n[Debug] Remove renderer override\n[Debug] Show renderer status\n"
    for i in $(seq 1 10); do menu="$menu""Switch view to Workspace $i\n"; done
    for i in $(seq 1 10); do menu="$menu""Move focused window to Workspace $i\n"; done
    # Ensure eww daemon is running and expand to brain-mode bar
    ''${pkgs.eww}/bin/eww daemon >/dev/null 2>&1 || true
    sleep 0.5
    # Close normal bar and open brain bar
    ''${pkgs.eww}/bin/eww close bar >/dev/null 2>&1 || true
    sleep 0.3
    ''${pkgs.eww}/bin/eww open bar_brain >/dev/null 2>&1 || true

    cleanup() {
      # Close brain bar and restore normal bar
      ''${pkgs.eww}/bin/eww close bar_brain >/dev/null 2>&1 || true
      sleep 0.3
      ''${pkgs.eww}/bin/eww open bar >/dev/null 2>&1 || true
    }
    trap cleanup EXIT

    CHOICE=$(printf "%b" "$menu" | rofi -dmenu -i -p "Omnibar" -mesg "$MESG")

    case "$CHOICE" in
      "Apps") rofi -show drun ;;
      "Open Terminal") kitty ;;
      "Close Active Window") hyprctl dispatch killactive ;;
      "Toggle Fullscreen on Active Window") hyprctl dispatch fullscreen 1 ;;
      "Exit Hyprland") hyprctl dispatch exit ;;
      "Screenshot region (grim+slurp)")
        # Screenshot toolchain: slurp selects region; grim saves PNG
        dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
        file="$dir/$(date +%F_%H-%M-%S)_region.png"
        geom=$(slurp) || exit 0
        grim -g "$geom" "$file" ;;
      "Screenshot full screen (grim)")
        # Screenshot tool: grim captures the whole output
        dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
        file="$dir/$(date +%F_%H-%M-%S)_full.png"
        grim "$file" ;;
      "[Box] A (Terminal)"|"[Box] B (Terminal)"|"[Box] C (Terminal)"|"[Box] D (Terminal)")
        kitty ;;
      "[Debug] Force renderer: pixman")
        mkdir -p "$HOME/.config/cognito"; echo pixman > "$HOME/.config/cognito/renderer"; notify-send "Renderer" "Override set to pixman. Log out to apply." ;;
      "[Debug] Force renderer: gl")
        mkdir -p "$HOME/.config/cognito"; echo gl > "$HOME/.config/cognito/renderer"; notify-send "Renderer" "Override set to gl. Log out to apply." ;;
      "[Debug] Remove renderer override")
        rm -f "$HOME/.config/cognito/renderer" && notify-send "Renderer" "Override removed. Auto-detect will apply on next login." || notify-send "Renderer" "No override to remove." ;;
      "[Debug] Show renderer status")
        OV="$HOME/.config/cognito/renderer"; SRC="auto"; OVV="-"
        if [ -f "$OV" ]; then SRC="override"; OVV=$(cat "$OV"); fi
        CUR=''${WLR_RENDERER:-unset}
        if systemd-detect-virt --quiet; then VM="yes"; else VM="no"; fi
        notify-send "Renderer status" "Current: $CUR\nOverride: $SRC''${OVV:+ ($OVV)}\nVM detected: $VM" ;;
      *)
        if printf "%s" "$CHOICE" | grep -q "^Switch view to Workspace "; then
          NUM=$(printf "%s" "$CHOICE" | awk '{print $NF}')
          hyprctl dispatch workspace "$NUM"
        elif printf "%s" "$CHOICE" | grep -q "^Move focused window to Workspace "; then
          NUM=$(printf "%s" "$CHOICE" | awk '{print $NF}')
          hyprctl dispatch movetoworkspace "$NUM"
        fi
        ;;
    esac
    ''')

    (pkgs.writeShellScriptBin "start-eww" ''
    #!/bin/sh
    # Manual eww startup for testing
    ''${pkgs.eww}/bin/eww daemon &
    sleep 1
    ''${pkgs.eww}/bin/eww open bar
    echo "Eww bar should now be visible at the top"
    ''')

    (pkgs.writeShellScriptBin "eww-daemon" ''
    #!/bin/sh
    # Eww daemon wrapper with proper environment
    export EWW_CONFIG_DIR=/etc/eww
    exec ''${pkgs.eww}/bin/eww daemon
    ''')

    (pkgs.writeShellScriptBin "eww-open" ''
    #!/bin/sh
    # Eww open wrapper with proper environment
    export EWW_CONFIG_DIR=/etc/eww
    exec ''${pkgs.eww}/bin/eww "$@"
    ''')

    (pkgs.writeShellScriptBin "start-hyprland-session" ''
    #!/bin/sh
    # Start Hyprland session target for systemd services
    systemctl --user start hyprland-session.target
    ''')
  ];
}
