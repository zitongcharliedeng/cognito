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
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
      XDG_RUNTIME_DIR = "/run/user/%i";
    };
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon -c ${StatusBar_BuiltOSPath}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
