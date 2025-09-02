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
  ];
  
  # Create xmobar config file using environment.etc
  environment.etc."xmobar/xmobarrc".text = builtins.readFile ./xmobarrc;

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
    wmctrl    # for window management and workspace info
    

    
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
        "send-workspace-1") xdotool key super+shift+1 ;;
        "send-workspace-2") xdotool key super+shift+2 ;;
        "send-workspace-3") xdotool key super+shift+3 ;;
        "send-workspace-4") xdotool key super+shift+4 ;;
        "send-workspace-5") xdotool key super+shift+5 ;;
        "send-workspace-6") xdotool key super+shift+6 ;;
        "send-workspace-7") xdotool key super+shift+7 ;;
        "send-workspace-8") xdotool key super+shift+8 ;;
        "send-workspace-9") xdotool key super+shift+9 ;;
        "send-workspace-10") xdotool key super+shift+0 ;;
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
    
    # Workspace preview script for xmobar
    (pkgs.writeScriptBin "workspace-preview" ''
      #!${pkgs.bash}/bin/bash
      
      # Get current workspace
      current_ws=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
      
      # Generate workspace preview
      preview=""
      for i in {0..9}; do
        # Get window count for this workspace
        window_count=$(wmctrl -l | awk -v ws="$i" '$2 == ws {count++} END {print count+0}')
        
        # Get window titles for this workspace (first 2)
        window_titles=$(wmctrl -l | awk -v ws="$i" '$2 == ws {print substr($0, index($0,$4))}' | head -2 | tr '\n' ' ' | sed 's/ $//')
        
        # Truncate long titles
        if [ ${#window_titles} -gt 15 ]; then
          window_titles="''${window_titles:0:12}..."
        fi
        
        # Set colors based on current workspace and window count
        if [ "$i" -eq "$current_ws" ]; then
          if [ "$window_count" -gt 0 ]; then
            icon="<fc=#68d391>●</fc>"
            color="<fc=#68d391>"
          else
            icon="<fc=#68d391>○</fc>"
            color="<fc=#68d391>"
          fi
        else
          if [ "$window_count" -gt 0 ]; then
            icon="<fc=#a0aec0>●</fc>"
            color="<fc=#a0aec0>"
          else
            icon="<fc=#4a5568>○</fc>"
            color="<fc=#4a5568>"
          fi
        fi
        
        # Add workspace to preview
        if [ "$i" -eq 9 ]; then
          ws_num="0"
        else
          ws_num="$((i+1))"
        fi
        
        preview="$preview<action=\`xdotool key super+$ws_num\`>$icon $color$ws_num</fc>"
        if [ -n "$window_titles" ]; then
          preview="$preview <fc=#718096>($window_titles)</fc>"
        fi
        preview="$preview</action> "
      done
      
      echo "$preview"
    '')
    
    # Custom omnibar script with explicit bash dependency
    (pkgs.writeScriptBin "cognito-omnibar" ''
      #!${pkgs.bash}/bin/bash
      
      # === COMMAND DEFINITIONS (DRY - Single Source of Truth) ===
      declare -A cmd_definitions=(
          # === APPLICATIONS ===
          ["kitty"]="kitty"
          ["thunar"]="thunar"
          ["firefox"]="firefox"
          ["vim"]="vim"
          ["gnome-control-center"]="gnome-control-center"
          
          # === WORKSPACES ===
          ["workspace-1"]="xmonad-cmd workspace-1"
          ["workspace-2"]="xmonad-cmd workspace-2"
          ["workspace-3"]="xmonad-cmd workspace-3"
          ["workspace-4"]="xmonad-cmd workspace-4"
          ["workspace-5"]="xmonad-cmd workspace-5"
          ["workspace-6"]="xmonad-cmd workspace-6"
          ["workspace-7"]="xmonad-cmd workspace-7"
          ["workspace-8"]="xmonad-cmd workspace-8"
          ["workspace-9"]="xmonad-cmd workspace-9"
          ["workspace-10"]="xmonad-cmd workspace-10"
          
          # === SEND TO WORKSPACE ===
          ["send-to-workspace-1"]="xmonad-cmd send-workspace-1"
          ["send-to-workspace-2"]="xmonad-cmd send-workspace-2"
          ["send-to-workspace-3"]="xmonad-cmd send-workspace-3"
          ["send-to-workspace-4"]="xmonad-cmd send-workspace-4"
          ["send-to-workspace-5"]="xmonad-cmd send-workspace-5"
          ["send-to-workspace-6"]="xmonad-cmd send-workspace-6"
          ["send-to-workspace-7"]="xmonad-cmd send-workspace-7"
          ["send-to-workspace-8"]="xmonad-cmd send-workspace-8"
          ["send-to-workspace-9"]="xmonad-cmd send-workspace-9"
          ["send-to-workspace-10"]="xmonad-cmd send-workspace-10"
          
          # === WINDOW MANAGEMENT ===
          ["close-window"]="xmonad-cmd close-window"
          ["split-window"]="xmonad-cmd split-window"
          ["fullscreen"]="xmonad-cmd fullscreen"
          ["toggle-float"]="xmonad-cmd toggle-float"
          
          # === FOCUS & MOVE ===
          ["focus-left"]="xmonad-cmd focus-left"
          ["focus-right"]="xmonad-cmd focus-right"
          ["focus-up"]="xmonad-cmd focus-up"
          ["focus-down"]="xmonad-cmd focus-down"
          ["move-left"]="xmonad-cmd move-left"
          ["move-right"]="xmonad-cmd move-right"
          ["move-up"]="xmonad-cmd move-up"
          ["move-down"]="xmonad-cmd move-down"
          
          # === LAYOUTS ===
          ["layout-stack"]="xmonad-cmd layout-stack"
          ["layout-tab"]="xmonad-cmd layout-tab"
          ["layout-toggle"]="xmonad-cmd layout-toggle"
          
          # === SYSTEM CONTROL ===
          ["shutdown"]="systemctl poweroff"
          ["reboot"]="systemctl reboot"
          ["logout"]="xmonad-cmd quit-xmonad"
          ["lock"]="i3lock"
          
          # === VOLUME CONTROL ===
          ["volume-up"]="amixer set Master 5%+"
          ["volume-down"]="amixer set Master 5%-"
          ["volume-mute"]="amixer set Master toggle"
          ["volume-unmute"]="amixer set Master unmute"
          ["volume-50"]="amixer set Master 50%"
          ["volume-100"]="amixer set Master 100%"
          
          # === BRIGHTNESS CONTROL ===
          ["brightness-up"]="brightnessctl set 5%+"
          ["brightness-down"]="brightnessctl set 5%-"
          ["brightness-max"]="brightnessctl set 100%"
          ["brightness-min"]="brightnessctl set 10%"
          ["brightness-50"]="brightnessctl set 50%"
          
          # === XMONAD CONTROL ===
          ["reload-config"]="xmonad --recompile && xmonad --restart"
          ["restart-xmonad"]="xmonad --restart"
          
          # === DEBUG & TEST ===
          ["debug"]="echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          ["test"]="notify-send 'Test' 'This is a test notification'"
          ["check-rofi"]="rofi -dmenu -i -p 'Rofi Test'"
          ["test-kitty"]="kitty"
          ["test-firefox"]="firefox"
          ["test-echo"]="echo 'Command execution test' && notify-send 'Test' 'Command executed successfully'"
          ["test-touch"]="touch /tmp/omnibar-test-file && notify-send 'Test' 'File created successfully'"
      )
      
      # === COMMAND ALIASES (Many-to-One Mapping) ===
      declare -A cmd_aliases=(
          # === APPLICATIONS ===
          ["new terminal"]="kitty"
          ["terminal"]="kitty"
          ["file manager"]="thunar"
          ["browser"]="firefox"
          ["web browser"]="firefox"
          ["text editor"]="vim"
          ["settings"]="gnome-control-center"
          
          # === WORKSPACES ===
          ["workspace 1"]="workspace-1"
          ["workspace 2"]="workspace-2"
          ["workspace 3"]="workspace-3"
          ["workspace 4"]="workspace-4"
          ["workspace 5"]="workspace-5"
          ["workspace 6"]="workspace-6"
          ["workspace 7"]="workspace-7"
          ["workspace 8"]="workspace-8"
          ["workspace 9"]="workspace-9"
          ["workspace 10"]="workspace-10"
          ["go to workspace 1"]="workspace-1"
          ["go to workspace 2"]="workspace-2"
          ["go to workspace 3"]="workspace-3"
          ["go to workspace 4"]="workspace-4"
          ["go to workspace 5"]="workspace-5"
          
          # === SEND TO WORKSPACE ALIASES ===
          ["send window to workspace 1"]="send-to-workspace-1"
          ["send window to workspace 2"]="send-to-workspace-2"
          ["send window to workspace 3"]="send-to-workspace-3"
          ["send window to workspace 4"]="send-to-workspace-4"
          ["send window to workspace 5"]="send-to-workspace-5"
          ["send window to workspace 6"]="send-to-workspace-6"
          ["send window to workspace 7"]="send-to-workspace-7"
          ["send window to workspace 8"]="send-to-workspace-8"
          ["send window to workspace 9"]="send-to-workspace-9"
          ["send window to workspace 10"]="send-to-workspace-10"
          ["move window to workspace 1"]="send-to-workspace-1"
          ["move window to workspace 2"]="send-to-workspace-2"
          ["move window to workspace 3"]="send-to-workspace-3"
          ["move window to workspace 4"]="send-to-workspace-4"
          ["move window to workspace 5"]="send-to-workspace-5"
          
          # === WINDOW MANAGEMENT ===
          ["close window"]="close-window"
          ["close this window"]="close-window"
          ["quit window"]="close-window"
          ["split horizontal"]="split-window"
          ["split vertical"]="split-window"
          ["split horizontally"]="split-window"
          ["split vertically"]="split-window"
          ["toggle fullscreen"]="fullscreen"
          ["floating window"]="toggle-float"
          ["toggle floating"]="toggle-float"
          ["maximize window"]="fullscreen"
          
          # === FOCUS & MOVE ===
          ["focus window left"]="focus-left"
          ["focus window right"]="focus-right"
          ["focus window up"]="focus-up"
          ["focus window down"]="focus-down"
          ["move window left"]="move-left"
          ["move window right"]="move-right"
          ["move window up"]="move-up"
          ["move window down"]="move-down"
          
          # === LAYOUTS ===
          ["layout stacking"]="layout-stack"
          ["layout tabbed"]="layout-tab"
          ["stacking layout"]="layout-stack"
          ["tabbed layout"]="layout-tab"
          ["tile layout"]="layout-tab"
          
          # === SYSTEM CONTROL ===
          ["shut down"]="shutdown"
          ["power off"]="shutdown"
          ["restart"]="reboot"
          ["log out"]="logout"
          ["exit xmonad"]="logout"
          ["lock screen"]="lock"
          
          # === VOLUME CONTROL ===
          ["volume mute"]="volume-mute"
          ["mute"]="volume-mute"
          ["unmute"]="volume-unmute"
          ["volume 50"]="volume-50"
          ["volume 100"]="volume-100"
          
          # === BRIGHTNESS CONTROL ===
          ["brightness max"]="brightness-max"
          ["brightness min"]="brightness-min"
          ["brightness 50"]="brightness-50"
          
          # === XMONAD CONTROL ===
          ["reload config"]="reload-config"
          ["restart xmonad"]="restart-xmonad"
          ["reload xmonad"]="restart-xmonad"
          ["restart window manager"]="restart-xmonad"
          
          # === DEBUG & TEST ===
          ["check rofi"]="check-rofi"
          ["test kitty"]="test-kitty"
          ["test firefox"]="test-firefox"
          ["test echo"]="test-echo"
          ["test touch"]="test-touch"
      )
      
      # Screenshot commands (complex, so defined separately)
      screenshot_cmd="scrot -d 1 ~/screenshot-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
      screenshot_window_cmd="scrot -s ~/screenshot-window-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-window-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
      screenshot_area_cmd="scrot -s ~/screenshot-area-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-area-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
      
      # === BUILD COMMAND LIST (Many-to-One Resolution) ===
      commands=()
      
      # Process aliases and resolve to actual commands
      for alias in "''${!cmd_aliases[@]}"; do
          cmd_key="''${cmd_aliases[$alias]}"
          if [[ -n "''${cmd_definitions[$cmd_key]}" ]]; then
              commands+=("$alias:''${cmd_definitions[$cmd_key]}")
          fi
      done
      
      # Add screenshot commands
      commands+=("screenshot:$screenshot_cmd")
      commands+=("screenshot window:$screenshot_window_cmd")
      commands+=("screenshot area:$screenshot_area_cmd")
      
      # Show commands with rofi
      if command -v rofi >/dev/null 2>&1; then
          input=$(printf '%s\n' "''${commands[@]}" | rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 60 -lines 20)
          
          if [[ -n "$input" ]]; then
              cmd=$(echo "$input" | cut -d: -f2)
              echo "Executing: $cmd"
              # Log to a file for debugging
              echo "$(date): Executing command: $cmd" >> /tmp/cognito-omnibar.log
              # Execute command directly in current shell context
              eval "$cmd" &
          fi
      else
          echo "Rofi not found"
      fi
    '')
  ];


}
