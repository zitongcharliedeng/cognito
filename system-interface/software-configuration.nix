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
    glf.environment.edition = "studio";
    environment.systemPackages = with pkgs; [
      osu-lazer-bin
      gnomeExtensions.vertical-workspaces # More intuitive since PaperVM has infinite horizontal space per workspace.
      gnomeExtensions.paperwm
      gnomeExtensions.just-perfection
    ];

    # Enable dconf for GNOME extension configuration
    programs.dconf.enable = true;

    # Configure GNOME extensions and status bar visibility
    programs.dconf.profiles."user".databases = [
      {
        settings = {
          "org/gnome/shell" = {
            enabled-extensions = [
              "paperwm@paperwm.github.com"
              "just-perfection-desktop@just-perfection"
              "vertical-workspaces@G-dH.github.com"
            ];
            disable-user-extensions = false;
          };
          "org/gnome/shell/extensions/just-perfection" = {
            panel = false;  # Hide the top panel in normal mode
            panel-in-overview = true;  # Show the top panel in overview mode
          };
        };
      }
    ];

    
  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
