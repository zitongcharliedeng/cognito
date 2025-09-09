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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible/glitchy cursors i.e. in screenshots, etc.
  };

  environment.etc."hypr/hyprland.conf".text = ''
  monitor=,1920x1080@60,auto,1  # TODO make this auto-detect
  env = XCURSOR_SIZE,24  # TODO make this custom
  exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &
  exec-once = start-hyprland-session
  input {
    kb_layout = us
  }
  general {
    gaps_in = 2 # Hyperland Default is 5 ಠ_ಠ
    gaps_out = 2 # Hyperland Default is 20 ಠ_ಠ
    border_size = 2 # Hyperland Default is 2 ಠ_ಠ
    # Hyperland does not guarantee the same default colors in new releases.
    col.active_border = rgba(ffffffff) # White
    col.inactive_border = rgba(000000ff) # Black
  }
  # Hide borders when a window is fullscreen
  windowrulev2 = noborder,fullscreen:1  # TODO: check if working
  $mod = SUPER
  bind = $mod,SPACE,exec,cognito-omnibar
  bind = $mod,RETURN,exec,kitty
  '';
}
