{ config, pkgs, lib, pkgs-unstable, ... }:

# User configuration for the default user created during GLF-OS installation
let
  userEnabledGnomeExtensions = [
    pkgs.gnomeExtensions.vertical-workspaces
    pkgs.gnomeExtensions.paperwm
    pkgs-unstable.gnomeExtensions.just-perfection
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

    "org/gnome/shell/extensions/just-perfection" = {
      panel = true;
      panel-in-overview = true;
      top-panel-position = 1; # 0 = top, 1 = bottom
    };
  };
}
