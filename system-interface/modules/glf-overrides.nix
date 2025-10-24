{ config, pkgs, lib, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # Multi-streaming on Twitch and YT done using Restream as the receiving service.
      obs-pipewire-audio-capture
      obs-vkcapture
      input-overlay
      # Live chat overlays like showing my YT and Twitch chat is done using a pinned steam browser in steam's shift-tab overlay.
      ##  And using Restream Chat for the pinned site.
    ];
  };
  # # Repo path: ./dotfiles/obs-studio (gittracked copy of the system's current ~/.config/obs-studio)
  # xdg.configFile."obs-studio" = {
  #   source = ./dotfiles/obs-studio;
  #   recursive = true;
  # };

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



