{ config, pkgs, lib, ... }:
let
  wallpaperCandidates = [
    ../wallpapers/wallpaper.png
    ../wallpapers/wallpaper.jpg
    ../wallpapers/wallpaper.jpeg
  ];
  CustomWallpaper_BuiltOSPaths = builtins.filter (p: builtins.pathExists p) wallpaperCandidates;
  Wallpaper_BuiltOSPath = if CustomWallpaper_BuiltOSPaths == [] then ./wallpapers/wallpaper.png else builtins.head CustomWallpaper_BuiltOSPaths;
in
{
  options = {
    cognito.hyprland.startCmd = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Command to start Hyprland session with VM-safe renderer selection.";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "_launch-hyprland-session" (builtins.readFile ./_launch-hyprland-session.sh))
    ];
    cognito.hyprland.startCmd = "_launch-hyprland-session";

    # Create Hyprland session target for systemd user services
    systemd.user.targets.hyprland-session = {
      description = "Hyprland session";
      unitConfig = {
        StopWhenUnneeded = false;
      };
    };

    # Hyprpaper wallpaper config; replace the path with your PNG if desired
    environment.etc."hypr/hyprpaper.conf".text = ''
    preload = ${Wallpaper_BuiltOSPath}
    wallpaper = ,${Wallpaper_BuiltOSPath}
    ipc = off
    '';
  };
}
