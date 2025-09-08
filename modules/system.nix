{ config, pkgs, ... }:
# Regression: autologin removed; XMonad/xmobar and custom rofi modes removed; X11 tools replaced by Wayland equivalents (wl-clipboard, grim, slurp); VMs often require 3D acceleration for Hyprland; hyprlock omitted on nixpkgs 23.11.
{
  services.openssh.enable = true;
  systemd.oomd.enable = false;

  nixpkgs.config.allowUnfree = true;

  users.users.root.isNormalUser = false;

  users.users.ulysses = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    initialPassword = "ulysses";
  };

  security.sudo.enable = true;

  services.xserver.enable = false;

  programs.hyprland.enable = true;

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
}
