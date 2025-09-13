{ config, pkgs, lib, ... }:
let
  wallpaperCandidates = [
    ./wallpapers/wallpaper.png
    ./wallpapers/wallpaper.jpg
    ./wallpapers/wallpaper.jpeg
  ];
  CustomWallpaper_BuiltOSPaths = builtins.filter (p: builtins.pathExists p) wallpaperCandidates;
  Wallpaper_BuiltOSPath = if CustomWallpaper_BuiltOSPaths == [] then ./wallpapers/wallpaper.png else builtins.head CustomWallpaper_BuiltOSPaths;
in
{
  imports = [ ./cog/default.nix ];
  
  config = {
    environment.systemPackages = with pkgs; [ 
      gtkgreet 
    ];
    
    services.xserver.enable = false;  # We are using Wayland, not X11.
    # 3D acceleration for Wayland. See README.md for more details.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.hyprland.enable = true;  # Wayland isn't a global toggle...
    # ... Wayland implicitly enabled by setting i.e. Hyprland as my window manager after signing in.
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
    };

    # Sign-in Screen.
    services.greetd.enable = true;
    services.greetd.settings = {
      default_session = {
        command = "exec Hyprland -c /etc/hypr/hyprland.conf";
        user = "ulysses";
      };
      greeter = {
        command = "${pkgs.gtkgreet}/bin/gtkgreet -l";
        user = "greeter";
      };
    };
    # Create greeter user for greetd
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
      home = "/var/lib/greeter";
      createHome = true;
    };
    users.groups.greeter = {};

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
    };


    # Hyprpaper wallpaper config; replace the path with your PNG if desired
    environment.etc."hypr/hyprpaper.conf".text = ''
    preload = ${Wallpaper_BuiltOSPath}
    wallpaper = ,${Wallpaper_BuiltOSPath}
    ipc = off
    '';

    environment.etc."hypr/hyprland.conf".text = ''
    monitor=,preferred,auto,1  # Auto-detect primary monitor resolution
    env = XCURSOR_SIZE,24  # TODO make this custom

    # Start window-manager environment programs
    exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &

    input {
      kb_layout = us
    }
    general {
      gaps_in = 2 # Hyprland Default is 5 ಠ_ಠ
      gaps_out = 2 # Hyprland Default is 20 ಠ_ಠ
      border_size = 2 # Hyprland Default is 2 ಠ_ಠ
      # Hyprland does not guarantee the same default colors in new releases.
      col.active_border = rgba(ffffffff) # White
      col.inactive_border = rgba(000000ff) # Black
    }
    
    # When any app is fullscreen on a workspace, remove gaps and borders
    workspace = f[1], gapsin:0, gapsout:0  # f[1] targets workspaces with maximized windows
    ## NOTE: f[0] (fullscreen) doesn't work, but f[1] (maximized) does work
    ## HYPOTHESIS: Some apps or Hyprland versions may interpret fullscreen states as maximized
    ## instead of true fullscreen, or there may be Wayland protocol differences in how
    ## fullscreen state is detected. f[1] works because maximized windows are more reliably
    ## detected by the workspace selector. See: https://wiki.hyprland.org/Configuring/Workspace-Rules/
    windowrulev2 = noborder,fullscreen:1

    $mod = SUPER
    # META+SPACE: Toggle omnibar overlay (closes if open, opens if closed)
    bind = $mod,SPACE,exec,toggle-omnibar-overlay
    '';
  };
}
