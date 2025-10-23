{ config, pkgs, lib, ... }:

# User configuration for the default user created during GLF-OS installation
{
  imports =
    [
      ./modules/last_deadlock_game_redlight.nix
    ];
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
    davinci-resolve-studio # v20 better than GLFos
    osu-lazer-bin
    # For the digitalzen installer:
    curl
    fuse3
    fuse                  # libfuse2 for older AppImages
    appimage-run
    desktop-file-utils    # provides update-desktop-database
    code-cursor         # AI coding.
    # Per app input and output effects i.e bitcrushed youtube music for streaming.
    carla
    qpwgraph
    calf # General audio plugins like eq, limiters, compressors, reverbs, etc.
  ];
  
  # Install DigitalZen on user activation (idempotent), gracefully keeps you logged in on rebuild even after running the script again.
  home.activation.digitalzenInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "[HM] Installing DigitalZen in user context..."
    ${pkgs.curl}/bin/curl -fsSL https://api.digitalzen.app/downloads/DigitalZen-setup.sh | ${pkgs.bash}/bin/bash || true
  '';
}
