{ config, pkgs, lib, ... }:

# User configuration for the default user created during GLF-OS installation
let
  userEnabledGnomeExtensions = [
    pkgs.gnomeExtensions.vertical-workspaces
    pkgs.gnomeExtensions.paperwm
    pkgs.gnomeExtensions.just-perfection
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
    # For the digitalzen installer:
    curl
    fuse3
    fuse                  # libfuse2 for older AppImages
    appimage-run
    desktop-file-utils    # provides update-desktop-database
  ];
  
  # User-specific configuration managed by home-manager
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = map (x: x.extensionUuid) userEnabledGnomeExtensions;
      disable-user-extensions = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      panel = false;
      panel-in-overview = true;
      top-panel-position = 1; # 0 = top, 1 = bottom
    };
  };

  # Install DigitalZen on user activation (idempotent), gracefully keeps you logged in on rebuild even after running the script again.
  home.activation.digitalzenInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "[HM] Installing DigitalZen in user context..."
    ${pkgs.curl}/bin/curl -fsSL https://api.digitalzen.app/downloads/DigitalZen-setup.sh | ${pkgs.bash}/bin/bash || true
  '';
}
