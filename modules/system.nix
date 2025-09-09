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
  imports = [ 
    ./window-manager/default.nix
    ./windows/default.nix
  ];
  services.openssh.enable = false; # Explicitly off; prevents accidental enablement by other modules. I never want to remote access via SSH, into my main OS.
  systemd.oomd.enable = false;  # Don't auto kill big processes. Cognito is a free land.

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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
    EWW_CONFIG_DIR = "/etc/eww";
  };







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
  exec-once = sleep 5 && eww open bar
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
  
  # Eww bar rules - proper patterns
  windowrulev2 = float, class:^(eww)$
  windowrulev2 = nofocus, class:^(eww)$
  windowrulev2 = opacity 0, fullscreen:1, class:^(eww)$
  
  # Rofi rules
  windowrulev2 = float, class:^(rofi)$
  windowrulev2 = nofocus, class:^(rofi)$

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
    :geometry (geometry :x "0px" :y "0px" :width "100%" :height "40px")
    :exclusive true
    :stacking "fg"
    :struts (struts :top 40)
    (box :class "bar" :orientation "v" :halign "fill" :valign "fill"
      (status_row)))

  (defwindow bar_brain
    :monitor 0
    :geometry (geometry :x "0px" :y "0px" :width "100%" :height "320px")
    :exclusive true
    :stacking "fg"
    :struts (struts :top 320)
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

  # Start eww daemon - simple and reliable
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
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
