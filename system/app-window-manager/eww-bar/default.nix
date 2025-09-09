{ config, pkgs, ... }:

let
  ewwConfigDir = toString ./.;
in

{
  # Add eww to system packages
  environment.systemPackages = with pkgs; [ eww ];

  # Start eww daemon with local config (following eureka-cpu's approach)
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${ewwConfigDir}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
