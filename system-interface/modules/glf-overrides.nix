{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # If any module tries to use pkgs.discord, it will resolve to vesktop-better-discord instead
      discord = prev.vesktop;
    })
  ];

  # Disable Firefox module from base layers to avoid collisions and cfg-specific expectations
  programs.firefox.enable = lib.mkForce false;

  # Also explicitly install vesktop at the system level for clarity in-case GLF-OS removes the default apps.
  environment.systemPackages = [ pkgs.vesktop pkgs.brave ];
}



