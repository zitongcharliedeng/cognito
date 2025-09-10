{ config, pkgs, ... }:

let
  StatusBar_BuiltOSPath = builtins.path {
    path = ./.;
    name = "status-bar";
  };
in
{
  environment.systemPackages = with pkgs; [ 
    eww 
    (pkgs.writeShellScriptBin "status-bar-state-refresher" (builtins.readFile ./status-bar-state-refresher.sh))
  ];

  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "hyprland-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${StatusBar_BuiltOSPath}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
