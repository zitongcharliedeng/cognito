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
    '';
  };
}
