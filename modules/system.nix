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
  
  # LightDM basic configuration TODO autofill the root username
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  
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
    neofetch  # system info display
    bat       # better cat with syntax highlighting
    fd        # better find command
    # Display manager packages
    kitty     # hardware-agnostic terminal
    scrot     # screenshot tool
    xfce.thunar  # file manager
    firefox   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
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
    
    # Debug: Auto-open terminal for troubleshooting
    exec --no-startup-id kitty

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier Mod4

    # THE ONLY KEYBOARD SHORTCUTS - Meta+Space or Alt+Space launches omnibar (like Apple Spotlight)
    bindsym Mod4+space exec cognito-omnibar
    bindsym Mod1+space exec cognito-omnibar

    # Window behavior
    new_window normal 1
    new_float normal

    # Focus behavior
    focus_follows_mouse no
    mouse_warping output

    # Workspace behavior
    workspace_auto_back_and_forth yes

    # No bar configuration - let i3 use defaults
  '';

  # Create simple test omnibar script using writeScriptBin
  environment.etc."cognito/omnibar.sh".source = pkgs.writeScriptBin "cognito-omnibar" ''
    #!/bin/bash
    
    # Simple test commands
    commands=(
        "new terminal:kitty"
        "file manager:thunar"
        "web browser:firefox"
        "test rofi:rofi -dmenu -i -p 'Test'"
        "debug:echo 'Omnibar working!'"
    )
    
    # Show commands with rofi
    if command -v rofi >/dev/null 2>&1; then
        input=$(printf '%s\n' "''${commands[@]}" | rofi -dmenu -i -p "🔍 Test Omnibar")
        
        if [[ -n "$input" ]]; then
            cmd=$(echo "$input" | cut -d: -f2)
            echo "Executing: $cmd"
            eval "$cmd"
        fi
    else
        echo "Rofi not found"
    fi
  '';

  # Create config symlinks
  systemd.tmpfiles.rules = [
    "L+ /root/.config/i3/config - - - - /etc/i3/config"
    "L+ /usr/bin/cognito-omnibar - - - - /etc/cognito/omnibar.sh"
  ];
  
  # Omnibar script will be made executable via tmpfiles
}
