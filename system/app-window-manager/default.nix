{ config, pkgs, ... }:

let
  StatusBar_BuiltOSPath = builtins.path {
    path = ./dropdown-status-bar;
    name = "dropdown-status-bar";
  };
  
  startEww = pkgs.writeShellScriptBin "start-eww" ''
    # Create eww config directory and copy files
    mkdir -p ~/.config/eww
    cp -r ${StatusBar_BuiltOSPath}/* ~/.config/eww/
    
    # Start daemon in background
    eww daemon &
    # Wait for daemon to be ready, then open both windows
    sleep 3
    eww open dropdown_status_bar_appearance
    eww open dropdown_status_bar_hitbox --arg hitbox_height_as_percentage="28%"
  '';
  
in
{
  imports = [ ./session/default.nix ./omnibar-mode/default.nix ./dropdown-status-bar/default.nix ];
  
  config = {
    environment.systemPackages = with pkgs; [ gtkgreet startEww ];
    
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
    monitor=,preferred,auto,1  # Auto-detect primary monitor resolution
    env = XCURSOR_SIZE,24  # TODO make this custom
    exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &
    exec-once = systemctl --user start hyprland-session.target
  # Start eww daemon and open window
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
    
    # Status bar rules - eww windows typically have class "eww" by default, TODO CHECK IF THESE ARE NEEDED
    windowrulev2 = float, class:^(eww)$
    windowrulev2 = nofocus, class:^(eww)$
    windowrulev2 = workspace 1, class:^(eww)$
    
    $mod = SUPER
    # META+SPACE: Toggle cognito-omnibar (closes if open, opens if closed)
    bind = $mod,SPACE,exec,if pgrep rofi >/dev/null; then pkill rofi; else cognito-omnibar; fi
    bind = $mod,RETURN,exec,kitty
    # META+F: Toggle fullscreen and update status bar
    bind = $mod,F,exec,hyprctl dispatch fullscreen && status-bar-state-refresher --update-once
    # META+E: Update status bar state (for debugging)
    bind = $mod,E,exec,status-bar-state-refresher
    
    # Workspace switching with status bar updates
    bind = $mod,1,exec,hyprctl dispatch workspace 1 && status-bar-state-refresher --update-once
    bind = $mod,2,exec,hyprctl dispatch workspace 2 && status-bar-state-refresher --update-once
    bind = $mod,3,exec,hyprctl dispatch workspace 3 && status-bar-state-refresher --update-once
    bind = $mod,4,exec,hyprctl dispatch workspace 4 && status-bar-state-refresher --update-once
    bind = $mod,5,exec,hyprctl dispatch workspace 5 && status-bar-state-refresher --update-once
    '';
  };
}
