{ config, pkgs, lib, ... }:

# User configuration for the default user created during GLF-OS installation
let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    vertical-workspaces
    paperwm
    just-perfection
  ];
in
{
  # Install GNOME extensions for this user
  home.packages = gnomeExtensions;
  
  # User-specific configuration managed by home-manager
  programs.dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = map (x: x.extensionUuid) gnomeExtensions;
      disable-user-extensions = false;
    };
    "org/gnome/shell/extensions/just-perfection" = {
      panel = false;
      panel-in-overview = true;
    };
  };
}
