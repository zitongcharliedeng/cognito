{ config, pkgs, ... }:

{
  imports = [
    ./actions/default.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      # Omnibar overlay script
      (pkgs.writeShellScriptBin "toggle-omnibar-overlay" (builtins.readFile ./toggle-omnibar-overlay.sh))
    ];
  };
}
