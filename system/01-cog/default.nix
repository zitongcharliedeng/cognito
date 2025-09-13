{ config, pkgs, lib, ... }:
{
  imports = [ ];
  
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
    // Niri configuration
    input {
        xkb {
            layout "us"
        }
    }
    
    // Set modifier key to Super for window resizing and scrolling
    modifier "Super"
    
    cursor {
        xcursor_theme "default"
        xcursor_size 24
    }
    
    outputs {
        // Auto-detect primary monitor resolution
        "*" {
            scale 1.0
        }
    }
    
    // Start window-manager environment programs
    // (No startup programs configured)
    
    // Window rules (commented out due to KDL syntax issues)
    // window-rule {
    //     match app-id ".*"
    //     fullscreen { borders = false }
    // }
    
    // Key bindings
    binds {
        // SUPER on release: Toggle omnibar overlay (with workspace overview)
        Super { spawn "toggle-omnibar-overlay"; }
    }
    '';
  };
}
