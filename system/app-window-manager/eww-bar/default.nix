{ config, pkgs, ... }:

let
  ewwBarDir = toString ./.;
in

{
  # Add eww to system packages
  environment.systemPackages = with pkgs; [ eww ];

  # Install eww bar configuration
  environment.etc."eww-bar/eww.yuck".text = builtins.readFile "${ewwBarDir}/eww.yuck";
  environment.etc."eww-bar/eww.scss".text = builtins.readFile "${ewwBarDir}/eww.scss";

  # Create symlink in user's home directory so eww finds config
  systemd.user.tmpfiles.rules = [
    "L+ /home/ulysses/.config/eww - - - - /etc/eww-bar"
  ];

  # Start eww daemon
  systemd.user.services.eww = {
    description = "Eww daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.eww}/bin/eww daemon --config /etc/eww-bar";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
