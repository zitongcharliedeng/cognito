{ config, pkgs, ... }:

let
  mynixui = builtins.path {
    path = ../../mynixui;
    name = "mynixui";
  };
  
  startEww = pkgs.writeShellScriptBin "start-eww" ''
    # Wait for daemon to be ready, then open window
    sleep 3
    eww open window -c ${mynixui}/eww &
  '';
in
{
  imports = [ ./session/default.nix ./omnibar-mode/default.nix ./eww-bar/default.nix ];
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
  exec-once = systemctl --user start hyprland-session.target
  exec-once = sleep 2 && ${startEww}/bin/start-eww
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
  
  # When any app is fullscreen on a workspace, remove gaps and borders
  workspace = f[1], gapsin:0, gapsout:0  # f[1] targets workspaces with maximized windows
  # NOTE: f[0] (fullscreen) doesn't work, but f[1] (maximized) does work
  # HYPOTHESIS: Some apps or Hyprland versions may interpret fullscreen states as maximized
  # instead of true fullscreen, or there may be Wayland protocol differences in how
  # fullscreen state is detected. f[1] works because maximized windows are more reliably
  # detected by the workspace selector. See: https://wiki.hyprland.org/Configuring/Workspace-Rules/
  windowrulev2 = noborder,fullscreen:1
  
  # Eww bar rules
  windowrulev2 = float, class:^(eww)$
  windowrulev2 = nofocus, class:^(eww)$
  windowrulev2 = workspace 1, class:^(eww)$
  
  $mod = SUPER
  bind = $mod,SPACE,exec,cognito-omnibar
  bind = $mod,RETURN,exec,kitty
  '';
}
