{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true; # :( Apps like Steam use proprietary drivers, closed source software.
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ulysses/.steam/root/compatibilitytools.d";
  };
}
