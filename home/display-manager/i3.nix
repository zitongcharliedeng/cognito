{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  # Graphical login
  services.xserver.displayManager.lightdm.enable = true;
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

  environment.systemPackages = with pkgs; [
    tmux
  ];
}
