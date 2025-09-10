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

# Remove systemd service - go back to the working startEww script approach
}
