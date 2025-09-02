{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "cognito-dev";

  # Don't manage bootloader in cloud
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # Hardware-specific X server configuration
  services.xserver.videoDrivers = [ "dummy" ];
  services.xserver.virtualScreen = {
    x = 1280;
    y = 800;
  };

  system.stateVersion = "23.11";
}

