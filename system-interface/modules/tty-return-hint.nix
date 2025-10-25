{ config, lib, pkgs, ... }:

let
  scriptPath = ./_tty-return-hint.sh;
in
{
  systemd.services."tty-return-hint" = {
    description = "Show VT hint and auto-switch back to tty1";
    after = [ "display-manager.service" "graphical.target" ];
    wants = [ "display-manager.service" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${scriptPath}";
      # Run as root to allow chvt
      User = "root";
      Group = "root";
    };
  };
}


