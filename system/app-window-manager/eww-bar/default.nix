{ config, pkgs, mynixui, ... }:

{
  # Add eww to system packages
  environment.systemPackages = with pkgs; [ eww ];

  # Copy eureka-cpu's exact approach: use mynixui flake
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${mynixui}/eww";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
