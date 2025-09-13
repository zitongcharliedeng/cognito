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
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
        WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
    };

    environment.etc."niri/config.kdl".text = ''
    
    # By default, Mod is equal to Super when running niri on a TTY, and to Alt when running niri as a nested winit window.
    input {
        mod-key "Super"
        mod-key-nested "Alt" # For use in a VM/ nested window manager.
        keyboard {
            xkb {
                layout "us"
            }
        }
    }

    binds {
        Mod+Space { spawn "toggle-omnibar-overlay"; }
    }
    '';
  };
}
