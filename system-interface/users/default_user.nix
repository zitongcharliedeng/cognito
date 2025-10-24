{ config, pkgs, lib, pkgsUnstable, ... }:

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
  home.packages = [
    pkgsUnstable.code-cursor         # AI coding.
    pkgsUnstable.davinci-resolve-studio # v20 better than GLFos's old version (19)
    pkgsUnstable.osu-lazer-bin
    # For the digitalzen installer: TODO wait for the planned nixpkg for DigitalZen.
    pkgs.curl
    pkgs.fuse3
    pkgs.fuse                  # libfuse2 for older AppImages
    pkgs.appimage-run
    pkgs.desktop-file-utils    # provides update-desktop-database
    # Per app input and output effects i.e bitcrushed youtube music for streaming.
    pkgs.carla
    pkgs.calf # General audio plugins like eq, limiters, compressors, reverbs, etc.
  ];
}
