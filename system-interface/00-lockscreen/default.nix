{ config, pkgs, lib, ... }:

let
  systemUsername = config.systemUsername;
in
{
  config = {
    environment.systemPackages = with pkgs; [ 
      tuigreet
      # Minimal wrapper: allow software renderer and capture logs for TTY2 debugging
      (pkgs.writeShellScriptBin "niri-session-soft-logged" ''
        #!/bin/sh
        set -eu
        export WLR_RENDERER_ALLOW_SOFTWARE=1
        mkdir -p "$HOME/.local/share"
        # Redirect stdout/stderr to a user log for inspection from TTY2
        exec niri-session >> "$HOME/.local/share/niri-session.log" 2>&1
      '')
    ];

    # Sign-in Screen default fixed to vt/tty1.
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Tuigreet with Wayland compatibility, remember username, show time
          # Launch niri via its session wrapper to ensure proper env/dbus setup
          # Run the standard niri session wrapper
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd niri-session";
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
