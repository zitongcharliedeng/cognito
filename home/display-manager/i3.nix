{ config, pkgs, ... }:

{
  imports = [ ../system.nix ];

  # Graphical login
  services.xserver.displayManager.lightdm.enable = true;
  
  # LightDM configuration to auto-fill username as root
  services.xserver.displayManager.lightdm.settings = {
    SeatDefaults = {
      greeter-hide-users = false;
      user-session = "i3";
      default-user = "root";
    };
  };
  
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu     # app launcher
      i3status  # default bar
      i3lock    # lock screen
      i3blocks  # optional bar
      alacritty # terminal (can swap for kitty)
    ];
  };
}
