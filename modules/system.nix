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
    EWW_CONFIG_DIR = "/etc/eww";
  };

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
    ${pkgs.eww}/bin/eww daemon >/dev/null 2>&1 || true
    sleep 0.5
    # Close normal bar and open brain bar
    ${pkgs.eww}/bin/eww close bar >/dev/null 2>&1 || true
    sleep 0.3
    ${pkgs.eww}/bin/eww open bar_brain >/dev/null 2>&1 || true

    cleanup() {
      # Close brain bar and restore normal bar
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
    '')

    (pkgs.writeShellScriptBin "start-eww" ''
    #!/bin/sh
    # Manual eww startup for testing
    ${pkgs.eww}/bin/eww daemon &
    sleep 1
    ${pkgs.eww}/bin/eww open bar
    echo "Eww bar should now be visible at the top"
    '')

    (pkgs.writeShellScriptBin "eww-daemon" ''
    #!/bin/sh
    # Eww daemon wrapper with proper environment
    export EWW_CONFIG_DIR=/etc/eww
    exec ${pkgs.eww}/bin/eww daemon
    '')

    (pkgs.writeShellScriptBin "eww-open" ''
    #!/bin/sh
    # Eww open wrapper with proper environment
    export EWW_CONFIG_DIR=/etc/eww
    exec ${pkgs.eww}/bin/eww "$@"
    '')

    (pkgs.writeShellScriptBin "start-hyprland-session" ''
    #!/bin/sh
    # Start Hyprland session target for systemd services
    systemctl --user start hyprland-session.target
    '')
  ];

  # Hyprpaper wallpaper config; replace the path with your PNG if desired
  environment.etc."hypr/hyprpaper.conf".text = ''
  preload = ${wallpaperPath}
  wallpaper = ,${wallpaperPath}
  ipc = off
  '';

  environment.etc."hypr/hyprland.conf".text = ''
  monitor=,1920x1080@60,auto,1
  env = XCURSOR_SIZE,24
  exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &
  exec-once = start-hyprland-session
  exec-once = sleep 3 && eww open bar
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
  
  # Ensure windows respect the bar's reserved space
  windowrulev2 = workspace 1,class:^(eww)$
  windowrulev2 = workspace 1,class:^(rofi)$
  
  # Configure eww bar behavior
  windowrulev2 = float,class:^(eww)$
  windowrulev2 = move 0 0,class:^(eww)$
  windowrulev2 = nofocus,class:^(eww)$
  windowrulev2 = noinitialfocus,class:^(eww)$
  windowrulev2 = pin,class:^(eww)$
  windowrulev2 = opacity 0,fullscreen:1,class:^(eww)$
  windowrulev2 = stayfocused,class:^(rofi)$
  windowrulev2 = nofocus,class:^(rofi)$

  $mod = SUPER
  bind = $mod,SPACE,exec,cognito-omnibar
  bind = $mod,RETURN,exec,kitty
  bind = $mod,Q,killactive
  bind = $mod,M,exit
  bind = $mod,F,fullscreen,1
  bind = $mod,ESCAPE,exec,pkill rofi
  bind = $mod SHIFT,SPACE,exec,pkill rofi
  '';

  # eww configuration (modular): variables, widgets, windows
  environment.etc."eww/eww.yuck".text = ''
  (include "variables.yuck")
  (include "widgets.yuck")
  (include "windows.yuck")
  '';

  environment.etc."eww/variables.yuck".text = ''
  (defpoll time :interval "1s" "date '+%H:%M'")
  '';

  environment.etc."eww/widgets.yuck".text = ''
  (defwidget status_row []
    (box :class "status-row" :space-evenly false :halign "fill" :valign "center"
      (box :class "left" :halign "start" :valign "center"
        (label :class "hint" :text "PRESS META+SPACE to open OMNIBAR"))
      (box :class "right" :halign "end" :valign "center"
        (label :class "clock" :text "{time}"))))

  (defwidget brain_grid []
    (grid :class "brain-grid" :halign "fill" :valign "fill" :row-spacing 6 :column-spacing 6 :rows 2 :columns 2
      (button :class "brain" :onclick "kitty" "A")
      (button :class "brain" :onclick "kitty" "B")
      (button :class "brain" :onclick "kitty" "C")
      (button :class "brain" :onclick "kitty" "D")))
  '';

  environment.etc."eww/windows.yuck".text = ''
  (defwindow bar
    :monitor 0
    :exclusive true
    :geometry (geometry :x 0 :y 0 :width "100%" :height 40)
    :stacking "fg"
    :struts (struts :side "top" :distance 40)
    :reserve (struts :side "top" :distance 40)
    (box :class "bar" :orientation "v" :halign "fill" :valign "fill"
      (status_row)))

  (defwindow bar_brain
    :monitor 0
    :exclusive true
    :geometry (geometry :x 0 :y 0 :width "100%" :height 320)
    :stacking "fg"
    :struts (struts :side "top" :distance 320)
    :reserve (struts :side "top" :distance 320)
    (box :class "bar brain-mode" :orientation "v" :halign "fill" :valign "fill"
      (brain_grid)
      (status_row)))
  '';

  environment.etc."eww/vars.scss".text = ''
  $bg: rgba(20,20,20,0.7);
  $bg_brain: rgba(20,20,20,0.8);
  $fg: #ffffff;
  $fg-muted: #cccccc;
  $tile: rgba(255,255,255,0.08);
  $tile-hover: rgba(255,255,255,0.18);
  '';

  environment.etc."eww/eww.scss".text = ''
  @import "vars";
  * { font-family: "${fontFamily}", monospace; }
  .bar { background: $bg; padding: 8px; }
  .brain-mode { background: $bg_brain; }
  .status-row { padding: 4px 8px; }
  .hint { color: $fg-muted; }
  .clock { color: $fg; }
  .brain-grid { padding: 8px; }
  .brain { background: $tile; color: $fg; border-radius: 8px; font-size: 20px; padding: 24px; }
  .brain:hover { background: $tile-hover; }
  '';

  # Create symlink in user's home directory so eww finds config
  systemd.user.tmpfiles.rules = [
    "L+ /home/ulysses/.config/eww - - - - /etc/eww"
  ];

  # Create Hyprland session target for systemd user services
  systemd.user.targets.hyprland-session = {
    description = "Hyprland session";
    unitConfig = {
      StopWhenUnneeded = false;
    };
  };

  # Start eww daemon only
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "hyprland-session.target" ];
    partOf = [ "hyprland-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

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
