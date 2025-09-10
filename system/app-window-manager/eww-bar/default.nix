{ config, pkgs, ... }:

let
  mynixuiStorePath = builtins.path {
    path = ../../../mynixui;
    name = "mynixui";
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
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${mynixuiStorePath}/eww";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
