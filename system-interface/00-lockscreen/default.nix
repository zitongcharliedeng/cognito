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

    # Sign-in Screen default fixed to vt/tty1.
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -l";
          user = systemUsername;
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
