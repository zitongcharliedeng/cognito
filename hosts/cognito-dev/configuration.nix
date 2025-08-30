{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "cognito-dev";

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot loader settings for VPS: don't install GRUB
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  system.stateVersion = "23.11";
}
