{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "cognito-omnibar" ''
    #!/bin/sh
    if pgrep rofi >/dev/null; then
      pkill rofi
      exit 0
    fi

    MESG="$(date '+%H:%M')  •  placeholder"

    menu="Apps\nOpen Terminal\nClose Active Window\nToggle Fullscreen on Active Window\nExit Hyprland\nScreenshot region (grim+slurp)\nScreenshot full screen (grim)\n[Debug] Force renderer: pixman\n[Debug] Force renderer: gl\n[Debug] Remove renderer override\n[Debug] Show renderer status\n"
    for i in $(seq 1 10); do menu="$menu""Switch view to Workspace $i\n"; done
    for i in $(seq 1 10); do menu="$menu""Move focused window to Workspace $i\n"; done

    ${pkgs.eww}/bin/eww daemon >/dev/null 2>&1 || true
    sleep 0.5
    ${pkgs.eww}/bin/eww close bar >/dev/null 2>&1 || true
    sleep 0.3
    ${pkgs.eww}/bin/eww open bar_brain >/dev/null 2>&1 || true

    cleanup() {
      ${pkgs.eww}/bin/eww close bar_brain >/dev/null 2>&1 || true
      sleep 0.3
      ${pkgs.eww}/bin/eww open bar >/dev/null 2>&1 || true
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
        dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
        file="$dir/$(date +%F_%H-%M-%S)_region.png"
        geom=$(slurp) || exit 0
        grim -g "$geom" "$file" ;;
      "Screenshot full screen (grim)")
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
        CUR="\${WLR_RENDERER:-unset}"
        if systemd-detect-virt --quiet; then VM="yes"; else VM="no"; fi
        notify-send "Renderer status" "Current: $CUR\nOverride: $SRC\${OVV:+ (\$OVV)}\nVM detected: $VM" ;;
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
    '')

    (pkgs.writeShellScriptBin "start-eww" ''
    #!/bin/sh
    ${pkgs.eww}/bin/eww daemon &
    sleep 1
    ${pkgs.eww}/bin/eww open bar
    echo "Eww bar should now be visible at the top"
    '')

    (pkgs.writeShellScriptBin "eww-daemon" ''
    #!/bin/sh
    export EWW_CONFIG_DIR=/etc/eww
    exec ${pkgs.eww}/bin/eww daemon
    '')

    (pkgs.writeShellScriptBin "eww-open" ''
    #!/bin/sh
    export EWW_CONFIG_DIR=/etc/eww
    exec ${pkgs.eww}/bin/eww "\$@"
    '')

    (pkgs.writeShellScriptBin "start-hyprland-session" ''
    #!/bin/sh
    systemctl --user start hyprland-session.target
    '')
  ];
}




