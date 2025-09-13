{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # Omnibar overlay script
      (pkgs.writeShellScriptBin "toggle-omnibar-overlay" (builtins.readFile ./toggle-omnibar-overlay.sh))
    ];
  };
}
