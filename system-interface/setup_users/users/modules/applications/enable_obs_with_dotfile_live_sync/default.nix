{ config, pkgs, lib, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      input-overlay
    ];
  };
  xdg.configFile."obs-studio" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/cognito/.config/obs-studio";
    force = true;
  };
}