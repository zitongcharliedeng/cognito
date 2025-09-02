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
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    

    
    # Custom omnibar script with explicit bash dependency
    (pkgs.writeScriptBin "cognito-omnibar" ''
      #!${pkgs.bash}/bin/bash
      
      # Comprehensive command database
      commands=(
          # === APPLICATIONS ===
          "new terminal:kitty"
          "terminal:kitty"
          "file manager:thunar"
          "browser:firefox"
          "web browser:firefox"
          "text editor:vim"
          "settings:gnome-control-center"
          "screenshot:scrot -d 1 ~/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved to ~/screenshot-$(date +%Y%m%d-%H%M%S).png'"
          "screenshot window:scrot -s ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved'"
          "screenshot area:scrot -s ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved'"
          
          # === WORKSPACES (1-10) ===
          "workspace 1:i3-msg workspace 1"
          "workspace 2:i3-msg workspace 2"
          "workspace 3:i3-msg workspace 3"
          "workspace 4:i3-msg workspace 4"
          "workspace 5:i3-msg workspace 5"
          "workspace 6:i3-msg workspace 6"
          "workspace 7:i3-msg workspace 7"
          "workspace 8:i3-msg workspace 8"
          "workspace 9:i3-msg workspace 9"
          "workspace 10:i3-msg workspace 10"
          "go to workspace 1:i3-msg workspace 1"
          "go to workspace 2:i3-msg workspace 2"
          "go to workspace 3:i3-msg workspace 3"
          "go to workspace 4:i3-msg workspace 4"
          "go to workspace 5:i3-msg workspace 5"
          
          # === WINDOW MANAGEMENT ===
          "close window:i3-msg kill"
          "close this window:i3-msg kill"
          "quit window:i3-msg kill"
          "split horizontal:i3-msg split h"
          "split vertical:i3-msg split v"
          "split horizontally:i3-msg split h"
          "split vertically:i3-msg split v"
          "fullscreen:i3-msg fullscreen toggle"
          "toggle fullscreen:i3-msg fullscreen toggle"
          "floating window:i3-msg floating toggle"
          "toggle floating:i3-msg floating toggle"
          "maximize window:i3-msg fullscreen toggle"
          
          # === FOCUS & MOVE ===
          "focus left:i3-msg focus left"
          "focus right:i3-msg focus right"
          "focus up:i3-msg focus up"
          "focus down:i3-msg focus down"
          "move left:i3-msg move left"
          "move right:i3-msg move right"
          "move up:i3-msg move up"
          "move down:i3-msg move down"
          "move window left:i3-msg move left"
          "move window right:i3-msg move right"
          "move window up:i3-msg move up"
          "move window down:i3-msg move down"
          
          # === LAYOUTS ===
          "layout stacking:i3-msg layout stacking"
          "layout tabbed:i3-msg layout tabbed"
          "layout toggle:i3-msg layout toggle split"
          "stacking layout:i3-msg layout stacking"
          "tabbed layout:i3-msg layout tabbed"
          "tile layout:i3-msg layout toggle split"
          
          # === SYSTEM CONTROL ===
          "shutdown:systemctl poweroff"
          "shut down:systemctl poweroff"
          "power off:systemctl poweroff"
          "reboot:systemctl reboot"
          "restart:systemctl reboot"
          "logout:i3-msg exit"
          "log out:i3-msg exit"
          "exit i3:i3-msg exit"
          "lock screen:i3lock"
          "lock:i3lock"
          
          # === VOLUME CONTROL ===
          "volume up:amixer set Master 5%+"
          "volume down:amixer set Master 5%-"
          "volume mute:amixer set Master toggle"
          "mute:amixer set Master toggle"
          "unmute:amixer set Master unmute"
          "volume 50:amixer set Master 50%"
          "volume 100:amixer set Master 100%"
          
          # === BRIGHTNESS CONTROL ===
          "brightness up:brightnessctl set 5%+"
          "brightness down:brightnessctl set 5%-"
          "brightness max:brightnessctl set 100%"
          "brightness min:brightnessctl set 10%"
          "brightness 50:brightnessctl set 50%"
          
          # === i3 CONTROL ===
          "reload config:i3-msg reload"
          "restart i3:i3-msg restart"
          "reload i3:i3-msg reload"
          "restart window manager:i3-msg restart"
          
          # === DEBUG & TEST ===
          "debug:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          "test:notify-send 'Test' 'This is a test notification'"
          "check rofi:rofi -dmenu -i -p 'Rofi Test'"
      )
      
      # Show commands with rofi
      if command -v rofi >/dev/null 2>&1; then
          input=$(printf '%s\n' "''${commands[@]}" | rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 60 -lines 20)
          
          if [[ -n "$input" ]]; then
              cmd=$(echo "$input" | cut -d: -f2)
              echo "Executing: $cmd"
              eval "$cmd"
          fi
      else
          echo "Rofi not found"
      fi
    '')
  ];

  # ============================================================================
  # COGNITO OMNIBAR CONFIGURATION
  # ============================================================================



  # Create config symlinks (like your friend's approach)
  # NOTE: We can't define i3/i3status configs directly in the NixOS configuration
  # because the i3 migration script fails to handle bar blocks and other directives.
  # Instead, we create separate config files and symlink them to avoid migration issues.
  systemd.tmpfiles.rules = [
    "L+ /root/.config/i3/config - - - - ${./i3config}"
    "L+ /root/.config/i3status/config - - - - ${./i3statusconfig}"
  ];
}
