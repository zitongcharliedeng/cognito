{ config, pkgs, StatusBar_BuiltOSPath, ... }:

{
  environment.systemPackages = with pkgs; [ 
    eww 
    (pkgs.writeShellScriptBin "status-bar-state-refresher" (builtins.readFile ./status-bar-state-refresher.sh))
  ];

  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${StatusBar_BuiltOSPath}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
