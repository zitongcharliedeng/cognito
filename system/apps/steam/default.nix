{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true; # :( Apps like Steam use proprietary drivers, closed source software.
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  # This is needed for some (i.e. Steam) app dialogs popups to work.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ulysses/.steam/root/compatibilitytools.d";
  };
}
