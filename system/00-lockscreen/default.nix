{ config, pkgs, lib, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [ 
      gtkgreet 
    ];

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
  };
}
