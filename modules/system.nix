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
    hyprpaper rofi-wayland jq
    obs-studio mangohud protonup
    wl-clipboard grim slurp
    kitty xfce.thunar firefox gnome-control-center libnotify alsa-utils brightnessctl papirus-icon-theme
    git htop

    (pkgs.writeShellScriptBin "cognito-omnibar" ''
    #!/bin/sh
    # Minimal inline overlay via rofi message (keeps config tiny and robust)
    MESG=$(printf '<span font_desc="%s 12">status row (WIP)</span>' "${fontFamily}")

    # Common rofi options: ignore user configs and avoid grabs
    ROFI_OPTS="-no-config -no-lazy-grab"

    # Start a persistent header loop; kill it after main rofi exits
    header_loop() {
      while :; do
        SEL=$(printf "Box A\nBox B\nBox C\nBox D\n" | rofi $ROFI_OPTS -dmenu -theme /etc/xdg/rofi/cognito-header.rasi -p "")
        [ -n "$SEL" ] && kitty &
      done
    }
    header_loop &
    HDR_PID=$!

    menu="Apps\nOpen Terminal\nClose Active Window\nToggle Fullscreen on Active Window\nExit Hyprland\nScreenshot region (grim+slurp)\nScreenshot full screen (grim)\n[Debug] Force renderer: pixman\n[Debug] Force renderer: gl\n[Debug] Remove renderer override\n[Debug] Show renderer status\n"
    for i in $(seq 1 10); do menu="$menu""Switch view to Workspace $i\n"; done
    for i in $(seq 1 10); do menu="$menu""Move focused window to Workspace $i\n"; done
    CHOICE=$(printf "%b" "$menu" | rofi $ROFI_OPTS -dmenu -i -p "Omnibar" -mesg "$MESG" -markup -theme /etc/xdg/rofi/cognito.rasi)

    # Stop header regardless of selection
    kill "$HDR_PID" 2>/dev/null || true

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
  ];

  # Rofi theme: larger window, semi-transparent background, message ABOVE input.
  environment.etc."xdg/rofi/cognito.rasi".text = ''
  configuration { show-icons: false; }
  * {
    font: "${fontFamily} 12";
    bg: rgba(20,20,20,0.50);
    fg: #ECEFF1;
    selbg: rgba(255,255,255,0.14);
    selfg: #FFFFFF;
  }
  window { background-color: @bg; width: 900px; height: 520px; border-radius: 8px; }
  mainbox { children: [ message, inputbar, listview ]; background-color: transparent; }
  message { padding: 8px 12px; text-color: @fg; background-color: transparent; }
  inputbar { padding: 8px 12px; background-color: rgba(0,0,0,0.35); border-radius: 6px; }
  prompt, textbox, element-icon { text-color: @fg; }
  listview { columns: 1; lines: 12; spacing: 6px; background-color: transparent; scrollbar: false; }
  element { padding: 10px 12px; border-radius: 6px; }
  element normal { background-color: transparent; text-color: @fg; }
  element selected { background-color: @selbg; text-color: @selfg; }
  '';

  # Header theme: fixed 4 columns; small bar at top (clickable buttons)
  environment.etc."xdg/rofi/cognito-header.rasi".text = ''
  configuration { show-icons: false; }
  * {
    font: "${fontFamily} 12";
    bg: rgba(20,20,20,0.65);
    fg: #FFFFFF;
    selbg: rgba(255,255,255,0.18);
  }
  window { background-color: @bg; width: 900px; height: 90px; border-radius: 8px; location: north; }
  mainbox { children: [ listview ]; }
  listview { columns: 4; lines: 1; spacing: 10px; background-color: transparent; scrollbar: false; fixed-height: true; }
  element { padding: 10px 12px; border-radius: 6px; background-color: rgba(255,255,255,0.08); }
  element selected { background-color: @selbg; text-color: @fg; }
  element-text { text-color: @fg; }
  '';

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
