{ config, pkgs, ... }:
# TODO rename home/ folder to really be system or hardware agnostic or main
{
  # ============================================================================
  # CORE SYSTEM CONFIGURATION (Hardware Agnostic)
  # ============================================================================
  
  # SSH service
  services.openssh.enable = true;
  
  # X server
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  
  # Auto-login for root (useful for headless/VM setups)
  services.getty.extraArgs = [ "--autologin" "root" ];
  
  # Root user configuration
  users.users.root = {
    isNormalUser = false;
    # Note: Password is the same as your NixOS installer sudo password
    # The initialPassword setting is ignored in this context
  };
  
  # ============================================================================
  # DISPLAY MANAGER - i3 + Cognito Omnibar
  # ============================================================================
  
  # Graphical login
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      rofi      # Apple-like omnibar launcher
      i3status  # status bar
      i3lock    # lock screen
    ];
  };

  # System packages (all hardware agnostic)
  environment.systemPackages = with pkgs; [
    # Core tools
    git
    vim
    htop
    tmux
    # Display manager packages
    kitty     # hardware-agnostic terminal
    scrot     # screenshot tool
    xfce.thunar  # file manager
    firefox   # web browser
    gnome.gnome-control-center # settings
  ];

  # ============================================================================
  # COGNITO OMNIBAR CONFIGURATION
  # ============================================================================

  # Generate i3 config with Apple-style omnibar
  environment.etc."i3/config".text = ''
    # Cognito OS i3 Configuration - Apple-style Omnibar Interface
    # Single keyboard shortcut (Meta+Space) launches omnibar from anywhere

    # Font for window titles and bar
    font pango:monospace 10

    # Start XDG autostart .desktop files
    exec --no-startup-id dex --autostart --environment i3

    # Essential services
    exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
    exec --no-startup-id nm-applet

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier Mod4

    # SINGLE KEYBOARD SHORTCUT - Meta+Space launches omnibar (like Apple Spotlight)
    bindsym Mod4+space exec cognito-omnibar

    # Window behavior
    new_window normal 1
    new_float normal

    # Focus behavior
    focus_follows_mouse no
    mouse_warping output

    # Workspace behavior
    workspace_auto_back_and_forth yes

    # Bar configuration
    bar {
        position top
        status_command i3status
        colors {
            background #2f343f
            statusline #ffffff
            separator #666666
            focused_background #285577
            focused_statusline #ffffff
            focused_separator #285577
        }
    }
  '';

  # Create Apple-style omnibar script
  environment.etc."cognito/omnibar.sh".text = ''
    #!/bin/bash
    # Cognito OS Omnibar - Apple Spotlight-style interface for i3
    # Launch with Meta+Space from anywhere, or click the status bar

    # Commands database with categories and descriptions
    declare -A commands=(
        # Terminal & Apps
        ["new terminal"]="kitty"
        ["open terminal"]="kitty"
        ["terminal"]="kitty"
        ["file manager"]="thunar"
        ["web browser"]="firefox"
        ["text editor"]="vim"
        ["settings"]="gnome-control-center"
        
        # Workspaces
        ["workspace 1"]="i3-msg workspace 1"
        ["workspace 2"]="i3-msg workspace 2"
        ["workspace 3"]="i3-msg workspace 3"
        ["workspace 4"]="i3-msg workspace 4"
        ["workspace 5"]="i3-msg workspace 5"
        ["workspace 6"]="i3-msg workspace 6"
        ["workspace 7"]="i3-msg workspace 7"
        ["workspace 8"]="i3-msg workspace 8"
        ["workspace 9"]="i3-msg workspace 9"
        ["workspace 10"]="i3-msg workspace 10"
        
        # Window Management
        ["close window"]="i3-msg kill"
        ["close this window"]="i3-msg kill"
        ["quit window"]="i3-msg kill"
        ["split horizontal"]="i3-msg split h"
        ["split vertical"]="i3-msg split v"
        ["split horizontally"]="i3-msg split h"
        ["split vertically"]="i3-msg split v"
        ["fullscreen"]="i3-msg fullscreen toggle"
        ["toggle fullscreen"]="i3-msg fullscreen toggle"
        ["floating window"]="i3-msg floating toggle"
        ["toggle floating"]="i3-msg floating toggle"
        
        # Focus & Move
        ["focus left"]="i3-msg focus left"
        ["focus right"]="i3-msg focus right"
        ["focus up"]="i3-msg focus up"
        ["focus down"]="i3-msg focus down"
        ["move left"]="i3-msg move left"
        ["move right"]="i3-msg move right"
        ["move up"]="i3-msg move up"
        ["move down"]="i3-msg move down"
        
        # Layouts
        ["layout stacking"]="i3-msg layout stacking"
        ["layout tabbed"]="i3-msg layout tabbed"
        ["layout toggle"]="i3-msg layout toggle split"
        
        # System
        ["reload config"]="i3-msg reload"
        ["restart i3"]="i3-msg restart"
        ["exit i3"]="i3-msg exit"
        ["lock screen"]="i3lock"
        ["screenshot"]="scrot"
    )

    # Create a more Apple-like interface with rofi (if available) or dmenu
    if command -v rofi >/dev/null 2>&1; then
        # Use rofi for a more polished Apple-like interface
        input=$(printf '%s\n' "''${!commands[@]}" | rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 50 -lines 15)
    else
        # Fallback to dmenu with better styling
        input=$(printf '%s\n' "''${!commands[@]}" | dmenu -i -p "🔍 Cognito Omnibar: " -l 15 -fn "monospace:size=12" -nb "#2d2d2d" -nf "#ffffff" -sb "#007acc" -sf "#ffffff")
    fi

    # Execute the command if found
    if [[ -n "$input" && -n "''${commands[$input]}" ]]; then
        eval "''${commands[$input]}"
    fi
  '';

  # Create custom i3status config with omnibar hint
  environment.etc."i3status.conf".text = ''
    general {
        colors = true
        interval = 5
    }

    order += "omnibar_hint"
    order += "disk /"
    order += "load"
    order += "memory"
    order += "tztime local"

    omnibar_hint {
        format = "🔍 Meta+Space for Omnibar"
        color = "#007acc"
    }

    disk "/" {
        format = "💾 %avail"
    }

    load {
        format = "⚡ %1min"
    }

    memory {
        format = "🧠 %used/%total"
        threshold_degraded = "1G"
        format_degraded = "🧠 %free"
    }

    tztime local {
        format = "🕐 %Y-%m-%d %H:%M:%S"
    }
  '';

  # Make omnibar executable and create config symlinks
  systemd.tmpfiles.rules = [
    "L+ /root/.config/i3/config - - - - /etc/i3/config"
    "L+ /root/.config/i3status/config - - - - /etc/i3status.conf"
    "L+ /usr/local/bin/cognito-omnibar - - - - /etc/cognito/omnibar.sh"
  ];
}
