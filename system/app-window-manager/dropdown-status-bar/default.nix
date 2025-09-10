{ config, pkgs, ... }:

let
  dropdownStatusBarStorePath = builtins.path {
    path = .;
    name = "dropdown-status-bar";
  };
in
{
  # Add eww to system packages
  environment.systemPackages = with pkgs; [ eww ];

  # Use local mynixui directory
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${dropdownStatusBarStorePath}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
