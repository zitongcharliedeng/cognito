{ config, pkgs, ... }:
let
  # Noto is the best practical base with broad symbol coverage ("no more tofu").
  # Prefer Noto Sans Mono; Noto Mono is older and narrower in glyph coverage.
  # Fallback will use non-mono Noto families when a glyph is missing.
  fontFamily = "Noto Sans Mono";
  lib = pkgs.lib;
  wallpaperCandidates = [
    ./assets/wallpapers/wallpaper.png
    ./assets/wallpapers/wallpaper.jpg
    ./assets/wallpapers/wallpaper.jpeg
  ];
  chosenWallpapers = builtins.filter (p: builtins.pathExists p) wallpaperCandidates;
  wallpaperPath = if chosenWallpapers == [] then ./assets/wallpapers/wallpaper.png else builtins.head chosenWallpapers;
  wallpaperExt = "." + (lib.last (lib.splitString "." (builtins.baseNameOf wallpaperPath)));
in
{
  imports = [ ./hyprland/session.nix ];
  services.openssh.enable = false; # Explicitly off; prevents accidental enablement by other modules. I never want to remote access via SSH, into my main OS.
  systemd.oomd.enable = false;  # Don't auto kill big processes. Cognito is a free land.
  nixpkgs.config.allowUnfree = true; # :( Apps like Steam use proprietary drivers, closed source software.

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" ];
  time.timeZone = "UTC";

  # Standard pattern: keep daily user as a normal account in the historical
  # "wheel" group (name comes from early Unix privileged users). This grants
  # sudo-based elevation for admin tasks while preserving a regular login/home
  # experience a typical non-root "customer" user would have.
  users.users.ulysses = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    initialPassword = "password";
  };
  security.sudo.enable = true; # Enable sudo for members of "wheel" when needed.

  services.xserver.enable = false;  # We are using Wayland, not X11.
  # 3D acceleration for Wayland. See README.md for more details.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.hyprland.enable = true;  # Wayland isn’t a global toggle...
  # ... It is implicitly enabled by using i.e. Hyprland as my window manager.

  # Sign-in Screen.
  services.greetd.enable = true;
  services.greetd.settings = {
    default_session = {
      command = config.cognito.hyprland.startCmd;  # VM-safe Hyprland session launcher
      user = "ulysses";
    };
  };
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ fontFamily ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ********************** START OF STEAM CONFIGURATION **********************
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  # This is needed for some (i.e. Steam) app dialogs popups to work.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ulysses/.steam/root/compatibilitytools.d";
  };
  # ********************** END OF STEAM CONFIGURATION **********************

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
    NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
  };

  # TODO add vm tools to develop NixOS in NixOS or figure out the dry-run NixOS changes with failsafe of rebooting without saving the changes to git. Dry running switch command i think it is called - add this action to the omnibar, with a NixOS icon. Same with the other common NixOS commands.
  environment.systemPackages = with pkgs; [
    hyprpaper rofi-wayland eww jq
    obs-studio mangohud protonup
    wl-clipboard grim slurp
    kitty xfce.thunar firefox gnome-control-center libnotify alsa-utils brightnessctl papirus-icon-theme
    git htop

    (pkgs.writeShellScriptBin "cognito-omnibar" ''
    #!/bin/sh
    # Start eww overlay with clock/workspaces while omnibar is open
    EWWCFG=/etc/eww
    eww -c "$EWWCFG" daemon 2>/dev/null || true
    eww -c "$EWWCFG" open --toggle omnibar_overlay

    menu="Apps\nOpen Terminal\nClose Active Window\nToggle Fullscreen on Active Window\nExit Hyprland\nScreenshot region (grim+slurp)\nScreenshot full screen (grim)\n[Debug] Force renderer: pixman\n[Debug] Force renderer: gl\n[Debug] Remove renderer override\n[Debug] Show renderer status\n"
    for i in $(seq 1 10); do menu="$menu""Switch view to Workspace $i\n"; done
    for i in $(seq 1 10); do menu="$menu""Move focused window to Workspace $i\n"; done
    CHOICE=$(printf "%b" "$menu" | rofi -dmenu -i -p "Omnibar")

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
    # Close overlay
    eww -c "$EWWCFG" close omnibar_overlay || true
    '')
  ];

  # Eww daemon as user service to ensure overlays show reliably at login
  systemd.user.services.eww = {
    Unit.Description = "Eww daemon";
    wantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pkgs.eww}/bin/eww -c /etc/eww daemon";
      Restart = "on-failure";
    };
  };

  environment.etc."eww/ws-preview.sh".text = ''
  #!/usr/bin/env bash
  set -euo pipefail
  active_ws=$(hyprctl -j monitors | jq 'map(select(.focused==true))[0].activeWorkspace.id')
  hyprctl -j workspaces | jq --argjson active "$active_ws" '
    sort_by(.id) | map({id:.id, name:(.name // (.id|tostring)), active:(.id==$active)})
  '
  '';

  environment.etc."eww/eww.yuck".text = ''
  (defwindow omnibar_overlay
    :geometry (geometry :x "50%" :y "8%" :anchor "top center" :width 480)
    :stacking "fg"
    :exclusive false
    (box :class "omnibar-overlay"
      :orientation "v"
      :spacing 8
      (box :halign "center" (label :class "clock" :text time))
      (box :halign "center" (label :class "date"  :text date))
      (box :class "workspaces" :orientation "h" :spacing 8
        (for ws in workspaces (box :class (concat "ws " (if (= (get ws :active) true) "active" ""))
          (label :text (get ws :name)))))
    ))

  (defwindow hint
    :geometry (geometry :x "50%" :y "96%" :anchor "bottom center" :width 520)
    :stacking "fg"
    :focusable false
    :exclusive false
    (box :class "hint"
      (label :text "PRESS META+SPACE to open OMNIBAR")))

  (defpoll time :interval "1s" "date +%H:%M")
  (defpoll date :interval "30s" "date +%a %d %b")
  (defpoll workspaces :interval "2s" "/etc/eww/ws-preview.sh")
  '';

  environment.etc."eww/eww.scss".text = ''
  .omnibar-overlay { background: rgba(0,0,0,0.6); padding: 10px 14px; border-radius: 8px; }
  .clock { font-size: 28px; font-weight: 600; }
  .date  { font-size: 14px; opacity: .9; }
  .workspaces { margin-top: 6px; }
  .ws { padding: 2px 6px; border-radius: 4px; background: rgba(255,255,255,0.05); }
  .ws.active { background: rgba(255,255,255,0.2); }
  .app { font-family: "${fontFamily}", monospace; font-size: 13px; }
  .hint { background: rgba(0,0,0,0.55); color: #fff; padding: 6px 10px; border-radius: 6px; font-size: 14px; letter-spacing: 0.5px; }
  '';

  # Hyprpaper wallpaper config; replace the path with your PNG if desired
  environment.etc."hypr/hyprpaper.conf".text = ''
  preload = ${wallpaperPath}
  wallpaper = ,${wallpaperPath}
  ipc = off
  '';
  
  environment.etc."ironbar/config.toml".text = ''
  [bar]
  layer = "top"
  anchor = "top"
  exclusivity = "exclusive"
  hide_on_fullscreen = true

  [[bar.start]]
  type = "workspaces"
  disable_scroll = true
  sort_by_number = true
  on_click = "hyprctl dispatch workspace %d"
  show_icons = true

  [[bar.center]]
  type = "clock"
  format = "%H:%M"

  [[bar.end]]
  type = "script"
  command = "sh -lc '[ \"$WLR_RENDERER\" = pixman ] && echo Pixman || echo Wayland\\ GL'"
  interval = 0

  [[bar.end]]
  type = "pulseaudio"

  [[bar.end]]
  type = "network"

  [[bar.end]]
  type = "battery"

  [[bar.end]]
  type = "script"
  command = "echo [ META+SPACE → Omnibar ]"
  interval = 0
  '';

  environment.etc."hypr/hyprland.conf".text = ''
  monitor=,1920x1080@60,auto,1
  env = XCURSOR_SIZE,24
  exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &
  # Ensure eww is running; show the hint briefly on login
  exec-once = eww -c /etc/eww daemon && (eww -c /etc/eww open hint & sleep 8 && eww -c /etc/eww close hint) &
  input {
    kb_layout = us
  }
  general {
    gaps_in = 2 # Hyperland Default is 5 ಠ_ಠ
    gaps_out = 2 # Hyperland Default is 20 ಠ_ಠ
    border_size = 2 # Hyperland Default is 2 ಠ_ಠ
    # Hyperland does not guarantee the same default colors in new releases.
    col.active_border = rgba(ffffffff) # White
    col.inactive_border = rgba(000000ff) # Black
  }
  decoration {
    rounding = 0
    blur {
      enabled = false
    }
    shadow {
      enabled = false
    }
  }
  # Hide borders when a window is fullscreen
  windowrulev2 = noborder,fullscreen:1
  $mod = SUPER
  bind = $mod,SPACE,exec,cognito-omnibar
  bind = $mod,RETURN,exec,kitty
  bind = $mod,Q,killactive
  bind = $mod,M,exit
  bind = $mod,F,fullscreen,1
  '';

  environment.etc."xdg/kitty/kitty.conf".text = ''
  font_family ${fontFamily}
  bold_font ${fontFamily} Bold
  italic_font ${fontFamily} Italic
  bold_italic_font ${fontFamily} Bold Italic
  '';

  environment.etc."xdg/rofi/config.rasi".text = ''
  configuration { font: "${fontFamily} 12"; }
  '';
}
