{ config, pkgs, ... }:

let
  # Get the directory containing this file
  omnibarDir = toString ./.;
in

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "cognito-omnibar" (builtins.readFile "${omnibarDir}/scripts/omnibar.sh"))
    (pkgs.writeShellScriptBin "start-eww" (builtins.readFile "${omnibarDir}/scripts/start-eww.sh"))
    (pkgs.writeShellScriptBin "eww-daemon" (builtins.readFile "${omnibarDir}/scripts/eww-daemon.sh"))
    (pkgs.writeShellScriptBin "eww-open" (builtins.readFile "${omnibarDir}/scripts/eww-open.sh"))
    (pkgs.writeShellScriptBin "start-hyprland-session" (builtins.readFile "${omnibarDir}/scripts/start-hyprland-session.sh"))
  ];
}