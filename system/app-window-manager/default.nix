{ config, pkgs, lib, ... }:
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
    programs.niri.enable = true;  # Wayland isn't a global toggle...
    # ... Wayland implicitly enabled by setting i.e. Niri as my window manager after signing in.
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
    };

    # Sign-in Screen.
    services.greetd.enable = true;
    services.greetd.settings = {
      default_session = {
        command = "niri";
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



    environment.etc."niri/config.kdl".text = ''
    // Niri configuration
    input {
        xkb {
            layout "us"
        }
    }
    
    // Set modifier key to Super for window resizing and scrolling
    modifier "Mod4"
    
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
    spawn-at-startup [
    ]
    
    // Window rules
    window-rules [
        // Remove borders for fullscreen windows
        {
            condition { app_id = ".*" }
            fullscreen { borders = false }
        }
    ]
    
    // Key bindings
    key-bindings {
        // SUPER on release: Toggle omnibar overlay (with workspace overview)
        Mod4 { spawn "toggle-omnibar-overlay" }
        // SUPER+O: Toggle workspace overview independently
        Mod4+O { spawn "niri action toggle-workspace-overview" }
        // META+RETURN: Open terminal
        Mod4+Return { spawn "kitty" }
        // META+F: Toggle fullscreen
        Mod4+F { focus-window-or-workspace 1 }
        // META+1-5: Switch workspaces
        Mod4+1 { focus-workspace 1 }
        Mod4+2 { focus-workspace 2 }
        Mod4+3 { focus-workspace 3 }
        Mod4+4 { focus-workspace 4 }
        Mod4+5 { focus-workspace 5 }
        // Screenshot bindings
        Mod4+Print { spawn "grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png" }
        Mod4+Shift+Print { spawn "grim -g \"$(slurp -o)\" ~/screenshot-$(date +%Y%m%d-%H%M%S).png" }
        Mod4+Ctrl+Print { spawn "grim -g \"$(slurp)\" ~/screenshot-$(date +%Y%m%d-%H%M%S).png" }
    }
    '';
  };
}
