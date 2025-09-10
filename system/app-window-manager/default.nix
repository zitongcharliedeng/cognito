{ config, pkgs, ... }:

let
  dropdownStatusBarStorePath = builtins.path {
    path = ./dropdown-status-bar;
    name = "dropdown-status-bar";
  };
  
  startEww = pkgs.writeShellScriptBin "start-eww" ''
    # Wait for daemon to be ready, then open window
    sleep 3
    eww open window -c ${dropdownStatusBarStorePath} &
  '';
in
{
  imports = [ ./session/default.nix ./omnibar-mode/default.nix ./dropdown-status-bar/default.nix ];
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
    gaps_in = 2 # Hyprland Default is 5 ಠ_ಠ
    gaps_out = 2 # Hyprland Default is 20 ಠ_ಠ
    border_size = 2 # Hyprland Default is 2 ಠ_ಠ
    # Hyprland does not guarantee the same default colors in new releases.
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
  
  # Eww bar rules - eww windows typically have class "eww" by default
  windowrulev2 = float, class:^(eww)$
  windowrulev2 = nofocus, class:^(eww)$
  windowrulev2 = workspace 1, class:^(eww)$
  
  # Control eww bar based on fullscreen state
  # When fullscreen: hide status bar (no physical space reservation)
  # When not fullscreen: show status bar (reserve physical space)
  windowrulev2 = exec, eww update hide_status_bar=true, class:^(eww)$, workspace:f[1]
  windowrulev2 = exec, eww update hide_status_bar=false, class:^(eww)$, workspace:f[-1]
  
  # Control eww bar based on rofi/cognito-omnibar state
  # When rofi is open: extend status bar to 25% height (dropdown mode)
  # When rofi is closed: normal status bar height
  # Note: rofi might not have class "rofi", so we use a more generic approach
  windowrulev2 = exec, eww update extend_status_bar=true, class:^(rofi)$
  windowrulev2 = exec, eww update extend_status_bar=false, class:^(rofi)$, focus:0
  
  # Alternative: Monitor rofi process lifecycle
  # This will be handled by the omnibar script itself
  
  # Alternative: if eww doesn't use class "eww", try these fallbacks:
  # windowrulev2 = float, title:^(eww)$
  # windowrulev2 = nofocus, title:^(eww)$
  # windowrulev2 = workspace 1, title:^(eww)$
  # windowrulev2 = opacity 0, title:^(eww)$, workspace:f[1]
  # windowrulev2 = opacity 1, title:^(eww)$, workspace:f[-1]
  
  $mod = SUPER
  # META+SPACE: Toggle cognito-omnibar (closes if open, opens if closed)
  bind = $mod,SPACE,exec,if pgrep rofi >/dev/null; then pkill rofi; else cognito-omnibar; fi
  bind = $mod,RETURN,exec,kitty
  '';
}
