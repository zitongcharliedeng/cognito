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

    # Ensure Mesa/DRM stack and GBM are available for KMS (required on TTY)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Ensure KMS driver loads early in VMs (harmless if unused)
    boot.initrd.kernelModules = [ "virtio_gpu" ];
    boot.kernelModules = [ "virtio_gpu" ];

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

    # Minimal userland for testing
    environment.systemPackages = with pkgs; [ kitty tuigreet ];

    # Minimal greetd autologin straight into niri via wrapper
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd niri-session";
          user = "greeter";
        };
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
