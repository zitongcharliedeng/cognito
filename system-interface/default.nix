{ config, pkgs, lib, ... }:
{
  imports = [ 
  ];

  # Export system username for other modules to use
  options.systemUsername = lib.mkOption {
    type = lib.types.str;
    default = "ulysses";
    description = "The primary system username";
  };

  config = {
    programs.niri.enable = true;

    # Autostart a terminal inside the session for testing
    systemd.user.services.kitty-autostart = {
      description = "Autostart kitty under Niri";
      after = [ "niri.service" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.kitty}/bin/kitty";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Provide a wrapper that forces software renderer for VM compatibility
    environment.systemPackages = with pkgs; [
      kitty
      (writeShellScriptBin "niri-autologin" ''
        #!/bin/sh
        set -eu
        export WLR_RENDERER=pixman
        export WLR_NO_HARDWARE_CURSORS=1
        export GBM_BACKENDS_PATH=${pkgs.mesa}/lib/gbm
        export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
        export __EGL_VENDOR_LIBRARY_DIRS=${pkgs.mesa}/share/glvnd/egl_vendor.d
        exec niri-session
      '')
    ];

    # Minimal greetd autologin straight into niri via wrapper
    services.greetd = {
      enable = true;
      settings.initial_session = {
        command = "niri-autologin";
        user = "ulysses";
      };
    };

    # Ensure the autologin user exists
    users.users.${config.systemUsername} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
      initialPassword = "password";
    };
  };
}
