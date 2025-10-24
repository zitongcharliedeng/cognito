{ config, pkgs, lib, pkgs-unstable, ... }:

{ 
  imports =
    [ # Include custom modules
      ./modules/mouse-pointer.nix
      ./modules/web-driver-device-access.nix
      ./modules/davinci-mic-fix.nix
      ./modules/glf-overrides.nix
      ./modules/syncing-application-data.nix
      ./modules/mcserver/mcserver.nix
      # ./modules/experimental/niri-session.nix TODO: later to maybe replace PaperWM. It has nice per-window blacking for fullscreen recordings but i like the stability of GNOME for now.
    ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    glf.environment.type = "plasma";
    
    glf.environment.edition = "studio-pro";  # Contains stuff like OBS, Steam, Davinci Resolve Studio (paid) etc.
    security.rtkit.enable = true;  # real-time scheduling for low-latency audio, possibly stops the twitch lagging-behind on audio vs the visuals

    environment.systemPackages = [
      pkgs.raysession
      pkgs.syncthing
      pkgs.apparmor-parser
      pkgs.apparmor-utils
    ];

    # Enable dconf system-wide for users to configure GNOME per user
    programs.dconf.enable = true;

    # Enable AppArmor (required by DigitalZen app and Flatpak)
    security.apparmor.enable = true;
    systemd.services.snapd.path = lib.mkAfter [ pkgs.apparmor-parser pkgs.apparmor-utils ];
    systemd.services."snapd.apparmor".path = lib.mkAfter [ pkgs.apparmor-parser pkgs.apparmor-utils ];
    systemd.services.snapd.environment.PATH = lib.mkForce "${pkgs.apparmor-parser}/bin:${pkgs.apparmor-utils}/bin:${config.system.path}/bin";
    systemd.services."snapd.apparmor".environment.PATH = lib.mkForce "${pkgs.apparmor-parser}/bin:${pkgs.apparmor-utils}/bin:${config.system.path}/bin";

    

    # Enable desktop portal for window capture (required for OBS PipeWire Game Capture)
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    # Enable home-manager for per-user configuration management
    home-manager.useGlobalPkgs = true;  # Use system's nixpkgs instead of home-manager's own copy
                                        # Prevents duplicate packages in Nix store and package conflicts
                                        # Faster builds since packages are already available from system
    home-manager.useUserPackages = true; # Install packages to user profile (~/.nix-profile) instead of system-wide
    home-manager.extraSpecialArgs.pkgsUnstable = pkgs-unstable;
    # Default user configuration - this is user-specific, not system-wide
    home-manager.users.${config._module.args.defaultUsername} = {
      # Ensure HM activation runs at switch and starts user units
      programs.home-manager.enable = true;
      systemd.user.startServices = "sd-switch";

      imports = [ ./users/default_user.nix ];
    };
    
  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
