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

  # Single symlink using .gitignore as the single source of truth.
  # Note: Nix-installed plugins (programs.obs-studio.plugins) live in the Nix store
  # (/nix/store/...) and are not under ~/.config/obs-studio, so this symlink does
  # not overwrite plugin binaries or their store paths.
  # Use a direct out-of-store symlink so edits land in the repo.
  home.file.".config/obs-studio" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/etc/nixos/system-interface/setup_users/users/modules/applications/enable_obs/dotfiles/obs-studio";
    force = true;
  };
}