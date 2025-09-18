{ config, pkgs, lib, ... }:

# User configuration for the default user created during GLF-OS installation
let
  userEnabledGnomeExtensions = with pkgs.gnomeExtensions; [
    vertical-workspaces
    paperwm
    hide-top-bar
  ];
in
{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Install user packages
  home.packages = with pkgs; [
    osu-lazer-bin
  ];
  
  # User-specific configuration managed by home-manager
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = map (x: x.extensionUuid) userEnabledGnomeExtensions;
      disable-user-extensions = false;
    };
    "org/gnome/shell/extensions/hide-top-bar" = {
      enable-active-window = false;  # keep hidden even with no active window
      show-in-overview = true;       # show only in overview
      mouse-sensitive = false;       # do NOT reveal on mouse hover
      pressure-sensitive = false;    # do NOT reveal on pressure push
      enable-multi-monitor = false;  # single-monitor setup
      only-primary = true;           # restrict to primary (no effect with one monitor)
    };
  };
}
