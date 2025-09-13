{ config, pkgs, ... }:
let
  # Noto is the best practical base with broad symbol coverage ("no more tofu").
  # Prefer Noto Sans Mono; Noto Mono is older and narrower in glyph coverage.
  # Fallback will use non-mono Noto families when a glyph is missing.
  fontFamily = "Noto Sans Mono";
  lib = pkgs.lib;
  systemUsername = "ulysses";
in
{
  imports = [ 
    ./00-lockscreen/default.nix
    ./01-cog/default.nix
    ./02-ito/default.nix
    ./02-ito/actions/window-manipulation/default.nix
    ./02-ito/actions/screenshotting/default.nix
  ];

  # Export system username for other modules to use
  options.systemUsername = lib.mkOption {
    type = lib.types.str;
    default = systemUsername;
    description = "The primary system username";
  };

  config = {
    services.openssh.enable = false; # Explicitly off; prevents accidental enablement by other modules. I never want to remote access via SSH, into my main OS.
    systemd.oomd.enable = false;  # Don't auto kill big processes. Cognito is a free land.

    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" ];
    time.timeZone = "UTC";

    # Standard pattern: keep daily user as a normal account in the historical
    # "wheel" group (name comes from early Unix privileged users). This grants
    # sudo-based elevation for admin tasks while preserving a regular login/home
    # experience a typical non-root "customer" user would have.
    users.users.${systemUsername} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
      initialPassword = "password";
    };
    security.sudo.enable = true; # Enable sudo for members of "wheel" when needed.

    # Fonts across the system
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ fontFamily ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
