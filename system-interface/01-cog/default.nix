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

    # Wayland session tweaks (safe defaults)
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      # Ensure wlroots/Niri find matching GBM backends from the same nixpkgs mesa
      GBM_BACKENDS_PATH = "${pkgs.mesa.drivers}/lib/gbm";
    };

    # Minimal niri config to ensure interactive keys on blank session
    environment.etc."niri/config.kdl".text = ''
    input {
        mod-key "Super"
        keyboard { xkb { layout "us" } }
    }

    binds {
        Mod+Return { spawn "kitty"; }
        Mod+Q { quit; }
    }
    
    # Autostart a visible client so we can see/detect draw/input even without binds
    spawn-at-startup "kitty";
    '';
  };
}
