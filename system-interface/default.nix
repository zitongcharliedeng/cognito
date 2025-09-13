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
    environment.systemPackages = with pkgs; [ kitty ];
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

    # Minimal greetd autologin straight into niri
    services.greetd = {
      enable = true;
      settings.initial_session = {
        command = "niri-session";
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
