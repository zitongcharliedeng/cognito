{ config, pkgs, lib, pkgsUnstable, ... }:

{
  imports = [
    ./modules/last_deadlock_game_redlight.nix
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


