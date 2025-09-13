{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # Window manipulation scripts
      (pkgs.writeShellScriptBin "close-current-window" (builtins.readFile ./close-current-window.sh))
      (pkgs.writeShellScriptBin "toggle-current-window-fullscreen" (builtins.readFile ./toggle-current-window-fullscreen.sh))
      (pkgs.writeShellScriptBin "switch-to-workspace" (builtins.readFile ./switch-to-workspace.sh))
      (pkgs.writeShellScriptBin "move-current-window-to-workspace" (builtins.readFile ./move-current-window-to-workspace.sh))
    ];
  };
}
