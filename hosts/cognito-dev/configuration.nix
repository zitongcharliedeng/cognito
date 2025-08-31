{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "cognito-dev";

  services.openssh.enable = true;
  services.getty.extraArgs = [ "--autologin" "root" ];

  # Don’t manage bootloader in cloud
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
  ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "dummy" ];
  services.xserver.virtualScreen = {
    x = 1280;
    y = 800;
  };

  # Allow X to autostart since this VM won’t have a TTY login
  services.xserver.displayManager.startx.enable = true;

  # Run a VNC server so you can see the desktop
  services.x11vnc = {
    enable = true;
    options = "-forever -nopw -display :0";
  };

  system.stateVersion = "23.11";
}

