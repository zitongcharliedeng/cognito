{ config, pkgs, ... }:

{
  imports = [
    ./window-manipulation/default.nix
    ./screenshotting/default.nix
  ];
}
