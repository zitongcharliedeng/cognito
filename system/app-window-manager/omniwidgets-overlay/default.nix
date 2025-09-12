{ config, pkgs, ... }:


{
  config = {
    environment.systemPackages = with pkgs; [
      # HyprPanel from nixpkgs (no home-manager needed)
      hyprpanel
      # Omniwidgets overlay management scripts
      (pkgs.writeShellScriptBin "_launch-omniwidgets-overlay" (builtins.readFile ./_launch-omniwidgets-overlay.sh))
      (pkgs.writeShellScriptBin "_reserve-status-bar-space" (builtins.readFile ./_reserve-status-bar-space.sh))
      (pkgs.writeShellScriptBin "_retract-status-bar-space" (builtins.readFile ./_retract-status-bar-space.sh))
    ];
  };
}