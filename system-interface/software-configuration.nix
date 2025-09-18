{ inputs, config, pkgs, lib, pkgs-unstable, ... }:

let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    vertical-workspaces
    paperwm
    just-perfection
  ];
  gnomeExtensionUuids = map (x: x.extensionUuid) gnomeExtensions;
in

{ 
  imports =
    [ # Include the results of the hardware scan + GLF modules
      ../system-hardware-shims/my-desktop/hardware-configuration.nix
      ../system-hardware-shims/my-desktop/firmware-configuration.nix
      ./modules/mouse-pointer.nix
      ./modules/web-driver-device-access.nix
      # ./modules/experimental/niri-session.nix TODO: later to maybe replace PaperWM.
    ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    glf.environment.type = "gnome";
    glf.environment.edition = "studio";
    
    # Install GNOME extensions
    environment.systemPackages = with pkgs; [
      osu-lazer-bin
    ] ++ gnomeExtensions;

    # Enable dconf for GNOME extension configuration
    programs.dconf.enable = true;

    # Configure default system GNOME extensions using system dconf profiles
    programs.dconf.profiles.user.databases = [{
      settings = lib.fix (_self: with lib.gvariant; {
        "org/gnome/shell" = {
          enabled-extensions = [
            pkgs.gnomeExtensions.vertical-workspaces.extensionUuid
            pkgs.gnomeExtensions.paperwm.extensionUuid
            pkgs.gnomeExtensions.just-perfection.extensionUuid
          ];
          disable-user-extensions = false;
        };
        "org/gnome/shell/extensions/just-perfection" = {
          panel = false;
          panel-in-overview = true;
        };
        # TODO: Disable welcome messages for extensions
      });
    }];

    # Systemd service to reset dconf to system defaults on login (like nix-shell behavior)
    systemd.user.services.reset-dconf-on-login = {
      description = "Reset dconf to system defaults on login. Users can edit dconf during session for testing, but changes are wiped on reboot as to not override the system dconf. Like nix-shell behavior.";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c ''
          # Reset dconf to system defaults (preserves session editing but resets on reboot)
          ${pkgs.dconf}/bin/dconf reset -f /org/gnome/shell/ 2>/dev/null || true
          # Reload system configuration
          ${pkgs.dconf}/bin/dconf update 2>/dev/null || true
          # Restart GNOME shell to apply system defaults
          ${pkgs.procps}/bin/killall -SIGUSR1 gnome-shell 2>/dev/null || true
        ''";
        User = "${config._module.args.systemUsername}";
      };
    };
    
  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
