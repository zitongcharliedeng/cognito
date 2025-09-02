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
  
  # GTK icon theme configuration (based on real NixOS configs)
  # This is necessary because Nix doesn't automatically register app icons in a central location
  # Desktop environments need icon themes to find icons for system UI elements and app fallbacks
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Papirus
    gtk-theme-name=Adwaita
  '';



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
    
    # Icon themes and packages (based on real NixOS configs)
    # IMPORTANT: Nix's immutable store means app icons are scattered across different paths
    # Even though apps come with their own icons, Nix doesn't automatically register them
    # in a central location that desktop environments can find. Icon themes provide:
    # 1. Centralized icon lookup for system UI elements (folders, tray, notifications)
    # 2. Fallback icons when app icons aren't found or properly registered
    # 3. Visual consistency across the entire desktop environment
    # This is a limitation of Nix's package management - we need icon packs as a workaround
    hicolor-icon-theme  # base icon theme (required fallback)
    papirus-icon-theme  # comprehensive icon theme with app icons
    gnome.adwaita-icon-theme  # GNOME default icons
    arc-icon-theme      # modern icon theme
    tango-icon-theme    # classic icon theme
    

    
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
        "workspace-10") echo "10" | xsel -i -b && xdotool key super+0 ;;
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
        "fullscreen") notify-send "Fullscreen" "Fullscreen toggle not yet implemented" ;;
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
    
    # Workspace preview script for xmobar (real app icons)
    (pkgs.writeScriptBin "workspace-preview" ''
      #!${pkgs.bash}/bin/bash
      
      # Get current workspace (with fallback)
      current_ws=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk '{print $3}' || echo "0")
      
      # Function to get app icon based on window class (icon theme lookup, letter fallback)
      # NOTE: Use icon theme as source of truth, fall back to first letter only if that fails
      get_app_icon() {
        local window_class="$1"
        local window_id="$2"
        local class_lower=$(echo "$window_class" | tr '[:upper:]' '[:lower:]')
        
        # Use gtk-icon-theme-name from GTK settings as the source of truth
        local icon_theme="Papirus"
        if [ -f "/etc/xdg/gtk-3.0/settings.ini" ]; then
          icon_theme=$(grep "gtk-icon-theme-name=" /etc/xdg/gtk-3.0/settings.ini 2>/dev/null | cut -d'=' -f2 || echo "Papirus")
        fi
        
        # Try to find icon in the configured icon theme
        local icon_path=""
        for theme_dir in /nix/store/*/share/icons/$icon_theme /run/current-system/sw/share/icons/$icon_theme /usr/share/icons/$icon_theme; do
          if [ -d "$theme_dir" ]; then
            # Look for icon by class name in the theme
            icon_path=$(find "$theme_dir" -name "*$class_lower*" -type f 2>/dev/null | head -1)
            [ -n "$icon_path" ] && break
          fi
        done
        
        # Return icon path if found, otherwise return first letter fallback
        if [ -n "$icon_path" ] && [ -f "$icon_path" ]; then
          echo "$icon_path"
        else
          # Absolute fallback: first letter of application class in caps
          local first_char=$(echo "$window_class" | cut -c1 | tr '[:lower:]' '[:upper:]')
          echo "$first_char"
        fi
      }
      
      # Function to get window class from window ID
      get_window_class() {
        local window_id="$1"
        xprop -id "$window_id" WM_CLASS 2>/dev/null | awk -F'"' '{print $4}' || echo ""
      }
      
      # Generate workspace preview
      preview=""
      for i in {1..10}; do
        # Get applications on this workspace
        app_icons=""
        if command -v wmctrl >/dev/null 2>&1; then
          # Get window IDs for this workspace (wmctrl uses 0-based indexing, so subtract 1)
          wmctrl_ws=$((i-1))
          window_ids=$(wmctrl -l 2>/dev/null | awk -v ws="$wmctrl_ws" '$2 == ws {print $1}' | head -3 || echo "")
          
          if [ -n "$window_ids" ]; then
            # Get icons for each window
            while IFS= read -r window_id; do
              if [ -n "$window_id" ]; then
                window_class=$(get_window_class "$window_id")
                if [ -n "$window_class" ]; then
                  icon_result=$(get_app_icon "$window_class" "$window_id")
                  # Check if result is a file path or a character
                  if [ -f "$icon_result" ]; then
                    # Extract app name from icon path for display (xmobar doesn't support <icon> tags)
                    # e.g., /path/to/firefox.svg -> F, /path/to/kitty.svg -> K
                    local app_name=$(basename "$icon_result" .svg | cut -c1 | tr '[:lower:]' '[:upper:]')
                    app_icons="$app_icons<fc=#68d391>$app_name</fc>"
                  else
                    # Display first letter fallback
                    app_icons="$app_icons<fc=#a0aec0>$icon_result</fc>"
                  fi
                fi
              fi
            done <<< "$window_ids"
          fi
        fi
        
        # Add workspace to preview with highlighting for current workspace
        ws_num="$i"
        
        # Determine the key to press (workspace 10 uses Super+0)
        if [ "$ws_num" -eq 10 ]; then
          key="0"
        else
          key="$ws_num"
        fi
        
        # Highlight current workspace (current_ws is 0-based, ws_num is 1-based)
        if [ "$ws_num" -eq "$((current_ws + 1))" ]; then
          # Current workspace - highlighted with underline
          if [ -n "$app_icons" ]; then
            preview="$preview<action=\`xdotool key super+$key\`><fc=#68d391><fn=2>$ws_num[$app_icons]</fn></fc></action> "
          else
            preview="$preview<action=\`xdotool key super+$key\`><fc=#68d391><fn=2>$ws_num[]</fn></fc></action> "
          fi
        else
          # Other workspaces - normal
          if [ -n "$app_icons" ]; then
            preview="$preview<action=\`xdotool key super+$key\`><fc=#a0aec0>$ws_num[$app_icons]</fc></action> "
          else
            preview="$preview<action=\`xdotool key super+$key\`><fc=#4a5568>$ws_num[]</fc></action> "
          fi
        fi
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
          ["restart-status-bar"]="pkill xmobar && sleep 1 && xmobar /etc/xmobar/xmobarrc &"
          
          # === TIME & DATE ===
          ["time"]="notify-send 'Time' \"\$(date '+%H:%M')\""
          ["date"]="notify-send 'Date' \"\$(date '+%A, %B %d, %Y')\""
          ["datetime"]="notify-send 'Date & Time' \"\$(date '+%A, %B %d, %Y at %H:%M')\""
          
          # === DEBUG & TEST ===
          ["debug"]="echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          ["test"]="notify-send 'Test' 'This is a test notification'"
          ["check-rofi"]="rofi -dmenu -i -p 'Rofi Test'"
          ["test-kitty"]="kitty"
          ["test-firefox"]="firefox"
          ["test-echo"]="echo 'Command execution test' && notify-send 'Test' 'Command executed successfully'"
          ["test-touch"]="touch /tmp/omnibar-test-file && notify-send 'Test' 'File created successfully'"
          ["test-xmobar"]="pkill xmobar 2>/dev/null || true; sleep 1; xmobar /etc/xmobar/xmobarrc &"
          ["debug-windows"]="wmctrl -l > /tmp/windows.txt && notify-send 'Debug' 'Window list saved to /tmp/windows.txt'"
          ["debug-workspace"]="xprop -root _NET_CURRENT_DESKTOP && notify-send 'Debug' 'Current workspace info shown in terminal'"
          ["debug-window-class"]="wmctrl -l | head -5 > /tmp/window-classes.txt && notify-send 'Debug' 'Window classes saved to /tmp/window-classes.txt'"
          ["debug-icon-theme"]="echo 'Testing icon theme lookup...' > /tmp/icon-theme.txt && echo 'GTK Icon Theme:' >> /tmp/icon-theme.txt && grep 'gtk-icon-theme-name=' /etc/xdg/gtk-3.0/settings.ini 2>/dev/null >> /tmp/icon-theme.txt && echo 'Papirus theme icons:' >> /tmp/icon-theme.txt && find /nix/store /run/current-system/sw/share /usr/share -path '*/icons/Papirus/*' -name '*kitty*' -o -name '*firefox*' 2>/dev/null | head -3 >> /tmp/icon-theme.txt && echo 'Fallback test: Kitty->K, Firefox->F' >> /tmp/icon-theme.txt && notify-send 'Debug' 'Icon theme lookup saved to /tmp/icon-theme.txt'"
          ["debug-workspace-preview"]="echo 'Debugging workspace preview...' > /tmp/workspace-debug.txt && echo 'wmctrl output:' >> /tmp/workspace-debug.txt && wmctrl -l >> /tmp/workspace-debug.txt && echo 'Current workspace:' >> /tmp/workspace-debug.txt && xprop -root _NET_CURRENT_DESKTOP >> /tmp/workspace-debug.txt && echo 'Workspace preview output:' >> /tmp/workspace-debug.txt && workspace-preview >> /tmp/workspace-debug.txt && notify-send 'Debug' 'Workspace preview debug saved to /tmp/workspace-debug.txt'"
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
          ["restart status bar"]="restart-status-bar"
          ["restart xmobar"]="restart-status-bar"
          
          # === TIME & DATE ALIASES ===
          ["what time is it"]="time"
          ["current time"]="time"
          ["what date is it"]="date"
          ["current date"]="date"
          ["date and time"]="datetime"
          ["current datetime"]="datetime"
          
          # === DEBUG & TEST ===
          ["check rofi"]="check-rofi"
          ["test kitty"]="test-kitty"
          ["test firefox"]="test-firefox"
          ["test echo"]="test-echo"
          ["test touch"]="test-touch"
          ["test xmobar"]="test-xmobar"
          ["launch xmobar"]="test-xmobar"
          ["start xmobar"]="test-xmobar"
          ["debug window class"]="debug-window-class"
          ["debug icon theme"]="debug-icon-theme"
          ["debug workspace preview"]="debug-workspace-preview"
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
