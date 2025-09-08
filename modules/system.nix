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

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    defaultFonts.monospace = [ "JetBrains Mono" "JetBrainsMono Nerd Font Mono" ];
  };

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

  # TODO add vm tools to develop NixOS in NixOS or figure out the dry-run NixOS changes with failsafe of rebooting without saving the changes to git. Dry running switch command i think it is called - add this action to the omnibar, with a NixOS icon. Same with the other common NixOS commands.
  environment.systemPackages = with pkgs; [
    waybar hyprpaper rofi-wayland
    obs-studio mangohud protonup
    wl-clipboard grim slurp
    kitty xfce.thunar firefox gnome-control-center libnotify alsa-utils brightnessctl papirus-icon-theme
    git vim htop tmux
    (pkgs.writeShellScriptBin "cognito-omnibar" ''
    #!/bin/sh
    CHOICE=$(printf "%s\n" "Apps" "Open Terminal" "Close Active Window" "Toggle Fullscreen" "Exit Hyprland" | rofi -dmenu -i -p "Omnibar")
    case "$CHOICE" in
      "Apps") rofi -show drun ;;
      "Open Terminal") kitty ;;
      "Close Active Window") hyprctl dispatch killactive ;;
      "Toggle Fullscreen") hyprctl dispatch fullscreen 1 ;;
      "Exit Hyprland") hyprctl dispatch exit ;;
    esac
    '')
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
  * { font-family: "JetBrains Mono", "JetBrainsMono Nerd Font Mono", monospace; font-size: 12px; }
  #workspaces button.active { color: #ffffff; background: #3a3a3a; }
  '';

  environment.etc."hypr/hyprland.conf".text = ''
  monitor=,1920x1080@60,auto,1
  env = XCURSOR_SIZE,24
  exec-once = waybar &
  input {
    kb_layout = us
  }
  general {
    gaps_in = 2 # Hyperland Default is 5 ಠ_ಠ
    gaps_out = 2 # Hyperland Default is 20 ಠ_ಠ
    border_size = 2 # Hyperland Default is 2 ಠ_ಠ
    # Hyperland does not guarantee the same default colors in new releases.
    col.active_border = rgba(ffffffff) # White
    col.inactive_border = rgba(808080ff) # 50% Grey
  }
  $mod = SUPER
  bind = $mod,SPACE,exec,cognito-omnibar
  bind = $mod,RETURN,exec,kitty
  bind = $mod,Q,killactive
  bind = $mod,M,exit
  bind = $mod,F,fullscreen,1
  '';

  environment.etc."xdg/kitty/kitty.conf".text = ''
  font_family JetBrainsMono Nerd Font Mono
  bold_font JetBrainsMono Nerd Font Mono Bold
  italic_font JetBrainsMono Nerd Font Mono Italic
  bold_italic_font JetBrainsMono Nerd Font Mono Bold Italic
  '';
}
