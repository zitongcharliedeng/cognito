{ config, pkgs, lib, ... }:

let
  systemUsername = config.systemUsername;
in
{
  config = {
    environment.systemPackages = with pkgs; [ 
      gtkgreet 
      cage
    ];

    # Sign-in Screen.
    services.greetd = {
      enable = true;

      # Run on TTY1
      vt = 1;

      settings = {
        default_session = {
          # Launch gtkgreet inside cage (minimal Wayland compositor)
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -l";
          user = "greeter";
        };
      };
    };

    # Configure gtkgreet to start niri after login
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
