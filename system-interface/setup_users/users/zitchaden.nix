{ config, pkgs, lib, pkgsUnstable, ... }:

{
  imports = [
    ./modules/services/enable_redlight.nix
    ./modules/applications/enable_crossover_appimage.nix
    ./modules/applications/enable_obs_with_dotfile_live_sync
    ./modules/applications/enable_plasma_with_dotfile_live_sync.nix
  ];

  home.stateVersion = "25.05";

  home.packages = [
    pkgsUnstable.code-cursor
    pkgsUnstable.davinci-resolve-studio
    pkgsUnstable.osu-lazer-bin
    pkgs.curl
    pkgs.fuse3
    pkgs.fuse
    pkgs.appimage-run
    pkgs.desktop-file-utils
    pkgs.carla
    pkgs.calf
  ];
}


