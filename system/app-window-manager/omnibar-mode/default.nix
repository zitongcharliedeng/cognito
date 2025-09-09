{ config, pkgs, ... }:

let
  # Get the directory containing this file
  omnibarDir = toString ./.;
in

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "cognito-omnibar" (builtins.readFile "${omnibarDir}/scripts/omnibar.sh"))
  ];
}