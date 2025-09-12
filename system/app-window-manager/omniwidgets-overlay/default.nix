{ config, pkgs, ... }:


{
  config = {
    environment.systemPackages = with pkgs; [
      # HyprPanel and Hyprshot packages
      hyprpanel
      hyprshot
      # Omniwidgets overlay management scripts
      (pkgs.writeShellScriptBin "_launch-ags-omniwidget-overlay" (builtins.readFile ./_launch-ags-omniwidget-overlay.sh))
      (pkgs.writeShellScriptBin "_reserve-status-bar-space" (builtins.readFile ./_reserve-status-bar-space.sh))
      (pkgs.writeShellScriptBin "_retract-status-bar-space" (builtins.readFile ./_retract-status-bar-space.sh))
      # Public user actions
      (pkgs.writeShellScriptBin "toggle-omnibar-overlay" (builtins.readFile ./toggle-omnibar-overlay.sh))
    ];

    # Fonts required by HyprPanel for icons
    fonts.packages = with pkgs; [
      jetbrains-mono  # NerdFont used by HyprPanel for icons
      nerd-fonts.jetbrains-mono  # JetBrainsMono NerdFont with icons
    ];
  };
}