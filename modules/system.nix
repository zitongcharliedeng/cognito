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
  # DISPLAY MANAGER - Awesome WM + Cognito Omnibar
  # ============================================================================
  
  # Graphical login
  services.xserver.displayManager.lightdm.enable = true;
  
  # LightDM basic configuration TODO autofill the root username
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  
  # Set XMonad as the default session (NixOS way)
  services.xserver.displayManager.defaultSession = "none+xmonad";
  


  # Enable XMonad, tried i3 and awesome to no avail
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = builtins.readFile ./xmonad.hs;
  };
  
  # Create xmobar configuration
  systemd.tmpfiles.rules = [
    "d /root/.config/xmobar 0755 root root -"
    "L+ /root/.config/xmobar/xmobarrc - - - - ${builtins.readFile ./xmobarrc}"
  ];

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
    xclip     # clipboard utility
    xfce.thunar  # file manager
    firefox   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    # XMonad WM dependencies
    rofi      # application launcher for omnibar
    feh       # wallpaper setter
    xdotool   # X11 automation tool for omnibar commands
    xsel      # clipboard utility for XMonad commands
    i3lock    # screen locker (used in omnibar commands)
    xmobar    # status bar for XMonad
    

    
    # XMonad command helper script
    (pkgs.writeScriptBin "xmonad-cmd" ''
      #!${pkgs.bash}/bin/bash
      
      case "$1" in
        "workspace-1") echo "1" | xsel -i -b && xdotool key super+1 ;;
        "workspace-2") echo "2" | xsel -i -b && xdotool key super+2 ;;
        "workspace-3") echo "3" | xsel -i -b && xdotool key super+3 ;;
        "workspace-4") echo "4" | xsel -i -b && xdotool key super+4 ;;
        "workspace-5") echo "5" | xsel -i -b && xdotool key super+5 ;;
        "workspace-6") echo "6" | xsel -i -b && xdotool key super+6 ;;
        "workspace-7") echo "7" | xsel -i -b && xdotool key super+7 ;;
        "workspace-8") echo "8" | xsel -i -b && xdotool key super+8 ;;
        "workspace-9") echo "9" | xsel -i -b && xdotool key super+9 ;;
        "workspace-10") echo "0" | xsel -i -b && xdotool key super+0 ;;
        "close-window") xdotool key super+shift+c ;;
        "split-window") xdotool key super+shift+return ;;
        "fullscreen") xdotool key super+f ;;
        "toggle-float") xdotool key super+shift+space ;;
        "focus-left") xdotool key super+h ;;
        "focus-right") xdotool key super+l ;;
        "focus-up") xdotool key super+k ;;
        "focus-down") xdotool key super+j ;;
        "move-left") xdotool key super+shift+h ;;
        "move-right") xdotool key super+shift+l ;;
        "move-up") xdotool key super+shift+k ;;
        "move-down") xdotool key super+shift+j ;;
        "layout-stack") xdotool key super+shift+s ;;
        "layout-tab") xdotool key super+shift+t ;;
        "layout-toggle") xdotool key super+space ;;
        "quit-xmonad") xdotool key super+shift+q ;;
        *) echo "Unknown command: $1" ;;
      esac
    '')
    
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
          "screenshot:scrot -d 1 ~/screenshot-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
          "screenshot window:scrot -s ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
          "screenshot area:scrot -s ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
          
          # === WORKSPACES (1-10) ===
          "workspace 1:xmonad-cmd workspace-1"
          "workspace 2:xmonad-cmd workspace-2"
          "workspace 3:xmonad-cmd workspace-3"
          "workspace 4:xmonad-cmd workspace-4"
          "workspace 5:xmonad-cmd workspace-5"
          "workspace 6:xmonad-cmd workspace-6"
          "workspace 7:xmonad-cmd workspace-7"
          "workspace 8:xmonad-cmd workspace-8"
          "workspace 9:xmonad-cmd workspace-9"
          "workspace 10:xmonad-cmd workspace-10"
          "go to workspace 1:xmonad-cmd workspace-1"
          "go to workspace 2:xmonad-cmd workspace-2"
          "go to workspace 3:xmonad-cmd workspace-3"
          "go to workspace 4:xmonad-cmd workspace-4"
          "go to workspace 5:xmonad-cmd workspace-5"
          
          # === WINDOW MANAGEMENT ===
          "close window:xmonad-cmd close-window"
          "close this window:xmonad-cmd close-window"
          "quit window:xmonad-cmd close-window"
          "split horizontal:xmonad-cmd split-window"
          "split vertical:xmonad-cmd split-window"
          "split horizontally:xmonad-cmd split-window"
          "split vertically:xmonad-cmd split-window"
          "fullscreen:xmonad-cmd fullscreen"
          "toggle fullscreen:xmonad-cmd fullscreen"
          "floating window:xmonad-cmd toggle-float"
          "toggle floating:xmonad-cmd toggle-float"
          "maximize window:xmonad-cmd fullscreen"
          
          # === FOCUS & MOVE ===
          "focus window left:xmonad-cmd focus-left"
          "focus window right:xmonad-cmd focus-right"
          "focus window up:xmonad-cmd focus-up"
          "focus window down:xmonad-cmd focus-down"
          "move window left:xmonad-cmd move-left"
          "move window right:xmonad-cmd move-right"
          "move window up:xmonad-cmd move-up"
          "move window down:xmonad-cmd move-down"
          
          # === LAYOUTS ===
          "layout stacking:xmonad-cmd layout-stack"
          "layout tabbed:xmonad-cmd layout-tab"
          "layout toggle:xmonad-cmd layout-toggle"
          "stacking layout:xmonad-cmd layout-stack"
          "tabbed layout:xmonad-cmd layout-tab"
          "tile layout:xmonad-cmd layout-tab"
          
          # === SYSTEM CONTROL ===
          "shutdown:systemctl poweroff"
          "shut down:systemctl poweroff"
          "power off:systemctl poweroff"
          "reboot:systemctl reboot"
          "restart:systemctl reboot"
          "logout:xmonad-cmd quit-xmonad"
          "log out:xmonad-cmd quit-xmonad"
          "exit xmonad:xmonad-cmd quit-xmonad"
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
          
          # === XMONAD CONTROL ===
          "reload config:xmonad --recompile && xmonad --restart"
          "restart xmonad:xmonad --restart"
          "reload xmonad:xmonad --restart"
          "restart window manager:xmonad --restart"
          
          # === DEBUG & TEST ===
          "debug:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          "test:notify-send 'Test' 'This is a test notification'"
          "check rofi:rofi -dmenu -i -p 'Rofi Test'"
          "test kitty:kitty"
          "test firefox:firefox"
          "test echo:echo 'Command execution test' && notify-send 'Test' 'Command executed successfully'"
          "test touch:touch /tmp/omnibar-test-file && notify-send 'Test' 'File created successfully'"
      )
      
      # Show commands with rofi
      if command -v rofi >/dev/null 2>&1; then
          input=$(printf '%s\n' "''${commands[@]}" | rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 60 -lines 20)
          
          if [[ -n "$input" ]]; then
              cmd=$(echo "$input" | cut -d: -f2)
              echo "Executing: $cmd"
              # Log to a file for debugging
              echo "$(date): Executing command: $cmd" >> /tmp/cognito-omnibar.log
              # Try multiple execution methods
              echo "Trying direct execution: $cmd" >> /tmp/cognito-omnibar.log
              # Method 1: Direct execution
              "$cmd" &
              # Method 2: Via awesome-client as backup
              awesome-client "awful.spawn('$cmd')" 2>/dev/null &
          fi
      else
          echo "Rofi not found"
      fi
    '')
  ];


}
