{ config, pkgs, ... }:

{
  # Enable SSH service
  services.openssh.enable = true;
  
  # Enable X server
  services.xserver.enable = true;
  
  # Allow X to autostart
  services.xserver.displayManager.startx.enable = true;
  
  # Auto-login for root (useful for headless/VM setups)
  services.getty.extraArgs = [ "--autologin" "root" ];
  
  # Basic system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux
  ];
  
  # Root user configuration
  users.users.root = {
    isNormalUser = false;
    initialPassword = "password";
  };
}
