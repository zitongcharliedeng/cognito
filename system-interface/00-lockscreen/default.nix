{ config, pkgs, lib, ... }:

let
  systemUsername = config.systemUsername;
in
{
  config = {
    environment.systemPackages = with pkgs; [ 
      tuigreet
      # Minimal wrapper: allow software renderer for wlroots to validate VM renderer path
      (pkgs.writeShellScriptBin "niri-session-soft" ''
        #!/bin/sh
        export WLR_RENDERER_ALLOW_SOFTWARE=1
        exec niri-session
      '')
    ];

    # Sign-in Screen default fixed to vt/tty1.
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Tuigreet with Wayland compatibility, remember username, show time
          # Launch niri via its session wrapper to ensure proper env/dbus setup
          # Temporarily use software renderer wrapper for confirmation
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd niri-session-soft";
          user = "greeter"; # greetd should always run as a system greeter user
        };
      };
    };

    # Configure tuigreet to list available sessions
    environment.etc."greetd/environments".text = ''
      niri
    '';

    # Create greeter user for greetd
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
      home = "/var/lib/greeter";
      createHome = true;
    };
    users.groups.greeter = {};
  };
}
