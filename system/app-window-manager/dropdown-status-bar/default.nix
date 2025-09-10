{ config, pkgs, ... }:

let
  StatusBar_BuiltOSPath = builtins.path {
    path = ./.;
    name = "dropdown-status-bar";
  };
in
{
  environment.systemPackages = with pkgs; [ 
    eww 
  ];

# Remove systemd service - go back to the working startEww script approach
}
