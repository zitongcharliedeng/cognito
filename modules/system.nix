{ config, pkgs, ... }:
# Regression: autologin removed; XMonad/xmobar and custom rofi modes removed; X11 tools replaced by Wayland equivalents (wl-clipboard, grim, slurp); VMs often require 3D acceleration for Hyprland; hyprlock omitted on nixpkgs 23.11.
{
  services.openssh.enable = true;
  systemd.oomd.enable = false;

  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" ];
  time.timeZone = "UTC";

  users.users.root.isNormalUser = false;

  users.users.ulysses = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    initialPassword = "password";
  };

  security.sudo.enable = true;

  services.xserver.enable = false;

  programs.hyprland.enable = true;

  services.greetd.enable = true;
  services.greetd.settings = {
    default_session = {
      command = "Hyprland -c /etc/hypr/hyprland.conf";
      user = "ulysses";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ulysses/.steam/root/compatibilitytools.d";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    waybar hyprpaper rofi-wayland
    obs-studio mangohud protonup
    wl-clipboard grim slurp
    kitty xfce.thunar firefox gnome-control-center libnotify alsa-utils brightnessctl papirus-icon-theme
    git vim htop tmux
  ];

  environment.etc."xdg/waybar/config.jsonc".text = ''
  {
    "layer": "top",
    "position": "top",
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "custom/omnibar"],
    "custom/omnibar": { "format": "[ META+SPACE → Omnibar ]" }
  }
  '';
  environment.etc."xdg/waybar/style.css".text = ''
  * { font-family: "Inter", "JetBrainsMono", sans-serif; font-size: 12px; }
  #workspaces button.active { color: #ffffff; background: #3a3a3a; }
  '';

  environment.etc."hypr/hyprland.conf".text = ''
  monitor=,preferred,auto,auto
  env = XCURSOR_SIZE,24
  exec-once = waybar &
  exec-once = rofi -show drun
  input {
    kb_layout = us
  }
  general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(00000088)
  }
  $mod = SUPER
  bind = $mod,SPACE,exec,rofi -show drun
  bind = $mod,RETURN,exec,kitty
  bind = $mod,Q,killactive
  bind = $mod,M,exit
  bind = $mod,F,fullscreen,1
  '';
}
