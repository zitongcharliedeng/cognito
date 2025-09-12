{ config, pkgs, ... }:

{
  imports = [ ./session/default.nix ./omniwidgets-overlay/default.nix ];
  
  config = {
    environment.systemPackages = with pkgs; [ 
      gtkgreet 
      # Atomic action scripts (preserved architecture)
      (pkgs.writeShellScriptBin "toggle-current-window-fullscreen" (builtins.readFile ./toggle-current-window-fullscreen.sh))
      (pkgs.writeShellScriptBin "switch-to-workspace" (builtins.readFile ./switch-to-workspace.sh))
      (pkgs.writeShellScriptBin "close-current-window" (builtins.readFile ./close-current-window.sh))
      (pkgs.writeShellScriptBin "move-current-window-to-workspace" (builtins.readFile ./move-current-window-to-workspace.sh))
      (pkgs.writeShellScriptBin "_sync-current-workspace-fullscreen-state" (builtins.readFile ./_sync-current-workspace-fullscreen-state.sh))
    ];
    
    services.xserver.enable = false;  # We are using Wayland, not X11.
    # 3D acceleration for Wayland. See README.md for more details.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.hyprland.enable = true;  # Wayland isn't a global toggle...
    # ... Wayland implicitly enabled by setting i.e. Hyprland as my window manager after signing in.
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

    # Start window-manager environment programs
    exec-once = hyprpaper -c /etc/hypr/hyprpaper.conf &
    exec-once = systemctl --user start hyprland-session.target
    exec-once = _launch-ags-omniwidget-overlay

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
    ## NOTE: f[0] (fullscreen) doesn't work, but f[1] (maximized) does work
    ## HYPOTHESIS: Some apps or Hyprland versions may interpret fullscreen states as maximized
    ## instead of true fullscreen, or there may be Wayland protocol differences in how
    ## fullscreen state is detected. f[1] works because maximized windows are more reliably
    ## detected by the workspace selector. See: https://wiki.hyprland.org/Configuring/Workspace-Rules/
    windowrulev2 = noborder,fullscreen:1

    $mod = SUPER
    # META+SPACE: Toggle omnibar overlay (closes if open, opens if closed)
    bind = $mod,SPACE,exec,toggle-omnibar-overlay
    bind = $mod,RETURN,exec,kitty
    # META+F: Toggle current window fullscreen (atomic operation with status bar update)
    bind = $mod,F,exec,toggle-current-window-fullscreen
    
    # Hyprshot screenshot commands
    bind = $mod,PRINT,exec,hyprshot -m output
    bind = $mod SHIFT,PRINT,exec,hyprshot -m window
    bind = $mod CTRL,PRINT,exec,hyprshot -m region
    
    # Workspace switching with status bar sync
    bind = $mod,1,exec,switch-to-workspace 1
    bind = $mod,2,exec,switch-to-workspace 2
    bind = $mod,3,exec,switch-to-workspace 3
    bind = $mod,4,exec,switch-to-workspace 4
    bind = $mod,5,exec,switch-to-workspace 5
    '';
  };
}
