{ config, pkgs, lib, pkgs-unstable, ... }:
# This current configuration works and runs steam games, albeit a bit laggy. It runs fine even with GNOME
# as the main session - the GNOME login manager is smart enough to create a new drop down session for Niri.
# (As long as other WM like PaperWM? is not installed)
{
  config = {
    # Enable Niri window manager (using unstable version for xwayland-satellite support)
    programs.niri.enable = true;
    programs.niri.package = pkgs-unstable.niri;
    
    # Fuzzel configuration (minimal setup, will replace with AGS later)
    # Fuzzel will be available as fuzzel in system packages
    # Configuration will be handled via AGS in the future
    
    # Ensure fuzzel can find applications
    # XDG_DATA_DIRS is the standard convention that fuzzel uses to find .desktop files
    # Add our paths to the existing XDG_DATA_DIRS from GLF-OS base (via NixOS display manager)
    environment.sessionVariables = {
      XDG_DATA_DIRS = lib.mkAfter [ "/usr/share/applications" "/usr/share/gnome/applications" ];
      # TODO: check if Wayland environment variables for Niri + Fuzzel are needed
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
    
    # Niri configuration - minimal keyboard shortcuts, everything else via Fuzzel
    environment.etc."niri/config.kdl".text = ''
      binds {
        Super+Space { spawn "fuzzel"; }
      }
    '';

    # System packages for Niri session
    environment.systemPackages = with pkgs; [
      fuzzel # Application Launcher - Fuzzel (modern Wayland launcher)
      (pkgs.writeShellScriptBin "fuzzel-commands" (builtins.readFile ./modules/additional-fuzzel-commands.sh))
      pkgs-unstable.xwayland-satellite # X11 support for Niri via xwayland-satellite (unstable)
    ];
  };
}
# TODO: reintroduce notifications via mako (or AGS later) this is the only thing lost by just removing the GNOME SHELL (front end)
 # TODO: Future AGS integration for advanced status bar and launcher
    # TODO: Implement streaming layout script for Niri using:
    # - Niri's layout system for 1:4:1 arrangement
    # - Window positioning via Niri's API
    # - Application launching and workspace management
    # 
    # Original streaming layout logic (commented for future revival):
    # 1. Launch applications: obs, steam, discord
    # 2. Wait for applications to load
    # 3. Get screen dimensions using xrandr or Niri's display API
    # 4. Calculate 1:4:1 layout ratios (top: 1/6, center: 4/6, bottom: 1/6)
    # 5. Use Niri's layout system to arrange windows programmatically
    # 6. Apply tiling constraints to prevent floating behavior
    #
    # Key differences for Niri implementation:
    # - Use Niri's layout system instead of GNOME Shell JavaScript API
    # - Use Niri's window management commands instead of Meta.Window
    # - Use Niri's workspace management for application placement
    # - Leverage Niri's mandatory tiling (no floating windows possible)

