{ config, pkgs, ... }:
{
  imports = [ ./session/default.nix ./omnibar-mode/default.nix ];
  services.xserver.enable = false;  # We are using Wayland, not X11.
  # 3D acceleration for Wayland. See README.md for more details.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.hyprland.enable = true;  # Wayland isn't a global toggle...
  # ... It is implicitly enabled by setting i.e. Hyprland as my window manager after signing in.
  environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";  # Tells Chromium-based apps to use Wayland.
  };

  # Sign-in Screen.
  environment.systemPackages = with pkgs; [ gtkgreet ];
  services.greetd.enable = true;
  services.greetd.settings = {
    default_session = {
      command = config.cognito.hyprland.startCmd;  # VM-safe Hyprland session launcher
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
}
