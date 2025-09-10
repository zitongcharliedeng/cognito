{ config, pkgs, ... }:

let
  mynixui = pkgs.runCommand "mynixui" {} ''
    cp -r ${./mynixui} $out
  '';
in
{
  # Add eww to system packages
  environment.systemPackages = with pkgs; [ eww ];

  # Use local mynixui directory
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
