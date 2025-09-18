{ inputs, config, pkgs, lib, pkgs-unstable, ... }:

let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    vertical-workspaces
    paperwm
    just-perfection
  ];
  gnomeExtensionUuids = map (x: x.extensionUuid) gnomeExtensions;
  # Convert extension UUIDs to dconf format: 'uuid1', 'uuid2', 'uuid3'
  commaListOfGnomeExtensionUuids = lib.concatMapStringsSep ", " (uuid: "'${uuid}'") gnomeExtensionUuids;
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

    # Create dconf database files in /etc/dconf/db/ so they can be loaded
    environment.etc."dconf/db/${config._module.args.systemUsername}.d/00-gnome-extensions" = {
      text = ''
        [org/gnome/shell]
        enabled-extensions=[${commaListOfGnomeExtensionUuids}]
        disable-user-extensions=false
        
        [org/gnome/shell/extensions/just-perfection]
        panel=false
        panel-in-overview=true
      '';
    };

    # Load dconf settings on login to ensure our configuration takes effect upon every session
    # Changes to GNOME Shell preferences are session-ephemeral, permanent changes must change the NixOS configuration.
    systemd.user.services.dconf-load = {
      description = "Load/override current dconf settings from system configuration";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c ''
          # Create dconf database directory if it doesn't exist i.e. on a new machine
          mkdir -p /etc/dconf/db/${config._module.args.systemUsername}.d
          # Load our GNOME extension settings
          ${pkgs.dconf}/bin/dconf load / < /etc/dconf/db/${config._module.args.systemUsername}.d/00-gnome-extensions
        ''";
        User = "${config._module.args.systemUsername}";
      };
    };

    
  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
