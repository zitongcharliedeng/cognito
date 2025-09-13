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
      GBM_BACKENDS_PATH = "${pkgs.mesa}/lib/gbm";
      # Force software renderer temporarily to bypass EGL/DRM issues in VM
      WLR_RENDERER = "pixman";
    };

    # Ensure these variables are really present in the niri systemd user service
    systemd.user.services.niri.serviceConfig.Environment = [
      # EGL/GLVND driver discovery
      "LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri"
      "__EGL_VENDOR_LIBRARY_DIRS=${pkgs.mesa}/share/glvnd/egl_vendor.d"
      # GBM and wlroots toggles
      "GBM_BACKENDS_PATH=${pkgs.mesa}/lib/gbm"
      "WLR_NO_HARDWARE_CURSORS=1"
      "WLR_RENDERER=pixman"
    ];

    # Do not ship a custom niri config; rely on module defaults while debugging
  };
}
