# /etc/nixos/hosts/cognito-dev/configuration.nix

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "cognito-dev";

  services.openssh.enable = true;
  
  services.getty.extraArgs = [ "--autologin" "root" ];

  # Don't manage the boot loader on this cloud PC as the provider does that allegedly
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # Enable X11 and LightDM
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  # Use i3 as the window manager
  services.xserver.windowManager.i3.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux   # for pane splitting test
  ];

  system.stateVersion = "23.11";
}

