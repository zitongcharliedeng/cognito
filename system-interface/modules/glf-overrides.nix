{ config, pkgs, lib, ... }:

let
  obsPlugins = with pkgs.obs-studio-plugins; [
    # Multi-streaming on Twitch and YT done using Restream as the receiving service.
    obs-pipewire-audio-capture # clean per-app audio capture
    obs-vkcapture              # Vulkan/OpenGL capture
    obs-scale-to-sound # poop avatar talking
    # Live chat overlays like showing my YT and Twitch chat is done using a pinned steam browser in steam's shift-tab overlay.
    # And using https://socialstream.ninja/docs/download.html for the pinned site.
  ];
in {
  programs.obs-studio = {
    enable = true;
    plugins = obsPlugins;
  };

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



