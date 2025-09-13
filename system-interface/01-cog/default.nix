{ config, pkgs, lib, ... }:
{
  imports = [ 
    ./apps/default.nix
  ];
  
  config = {
    services.xserver.enable = false;  # We are using Wayland, not X11.
    # 3D acceleration for Wayland. See README.md for more details.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.niri.enable = true;  # Wayland isn't a global toggle...
    # ... Wayland implicitly enabled by setting i.e. Niri as my window manager after signing in.
    
    # XDG Portal configuration for popups like Steam login, and maybe Niri to run right?
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = ["gnome" "gtk"];
        };
        niri = {
          default = ["gnome" "gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
          "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
        WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
    };

    environment.etc."niri/config.kdl".text = ''
    input {
        mod-key "Super"
        keyboard {
            xkb {
                layout "us"
            }
        }
    }

    binds {
        Mod+Space { spawn "toggle-omnibar-overlay"; }
        Mod+Return { spawn "kitty"; }
        Mod+Q { quit; }
    }

    layout {
        gaps 8
    }
    '';
  };
}
