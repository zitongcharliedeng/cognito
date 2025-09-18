{ inputs, config, pkgs, lib, pkgs-unstable, ... }:

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
    glf.environment.edition = "studio";  # Contains stuff like OBS, Steam, etc.

    # Enable dconf system-wide for users to configure GNOME per user
    programs.dconf.enable = true;

    # Enable home-manager for per-user configuration management
    home-manager.useGlobalPkgs = true;  # Use system's nixpkgs instead of home-manager's own copy
                                        # Prevents duplicate packages in Nix store and package conflicts
                                        # Faster builds since packages are already available from system
    home-manager.useUserPackages = true; # Install packages to user profile (~/.nix-profile) instead of system-wide
                                         # Keeps user-specific packages separate from system packages
                                         # Better for multi-user systems and cleaner separation of concerns

    # Default user configuration - this is user-specific, not system-wide
    home-manager.users.${config._module.args.defaultUsername} = {
      imports = [ ./users/default_user.nix ];
    };
    
  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
