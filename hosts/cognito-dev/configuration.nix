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

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true; # use startx instead of lightdm
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps; # use i3-gaps for better visuals
    };
  };

  # Auto-start X (and i3) after root autologin
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec startx
    fi
  '';

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux   # for pane splitting test
  ];

  system.stateVersion = "23.11";
}

