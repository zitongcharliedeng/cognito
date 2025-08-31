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
  
  # TODO move this out of a machine-specific config module
  users.users.root = {
    isNormalUser = false;
    initialPassword = "password";  # 👈 plain password
  };

  users.users.cognitodev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "password";
  };


  # Allow X to autostart since this VM won’t have a TTY login
  services.xserver.displayManager.startx.enable = true;

  system.stateVersion = "23.11";
}

