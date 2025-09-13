{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # Screenshot scripts
      (pkgs.writeShellScriptBin "screenshot-region" (builtins.readFile ./screenshot-region.sh))
      (pkgs.writeShellScriptBin "screenshot-fullscreen" (builtins.readFile ./screenshot-fullscreen.sh))
      (pkgs.writeShellScriptBin "screenshot-window" (builtins.readFile ./screenshot-window.sh))
      (pkgs.writeShellScriptBin "screenshot-output" (builtins.readFile ./screenshot-output.sh))
    ];
  };
}
