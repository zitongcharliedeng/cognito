{ config, pkgs, ... }:
# TODO rename home/ folder to really be system or hardware agnostic or main
{
  # ============================================================================
  # CORE SYSTEM CONFIGURATION (Hardware Agnostic)
  # ============================================================================
  services.openssh.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.getty.extraArgs = [ "--autologin" "root" ];
  users.users.root = {
    isNormalUser = false;
    # Note: Password is the same as your NixOS installer sudo password
    # The initialPassword setting is would be ignored in this context after install.sh runs
  };
  
  # ============================================================================
  # DISPLAY MANAGER - XMonad on X11, with Rofi Omnibar for no-memorized shortcuts
  # ============================================================================
  
  # Graphical login screen
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  
  services.xserver.displayManager.defaultSession = "none+xmonad"; # tried i3 and awesome to no avail
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = builtins.readFile ./xmonad.hs;
  };
  
  # Create configuration for xmobar, the status bar for XMonad
  systemd.tmpfiles.rules = [
    "d /root/.config/xmobar 0755 root root -"
  ];
  environment.etc."xmobar/xmobarrc".text = builtins.readFile ./xmobarrc;

  # ============================================================================
  # SYSTEM PACKAGES (all hardware agnostic)
  # ============================================================================
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux
    kitty     # hardware-agnostic terminal
    scrot     # screenshot tool
    xclip     # clipboard utility
    xfce.thunar  # file manager and explorer
    firefox   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    rofi      # application launcher for omnibar
    xdotool   # X11 automation tool for omnibar commands
    xsel      # clipboard utility for XMonad commands
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
                    app_name=$(basename "$icon_result" .svg | cut -c1 | tr '[:lower:]' '[:upper:]')
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
      
      # === SIMPLE DIRECT COMMANDS (One Entry Per Action) ===
      commands=(
          # === APPLICATIONS ===
          "open kitty in new window:kitty"
          "open thunar in new window:thunar"
          "open firefox in new window:firefox"
          "open vim in new window:vim"
          "open settings in new window:gnome-control-center"
          
          # === WORKSPACES ===
          "switch to workspace 1:xmonad-cmd workspace-1"
          "switch to workspace 2:xmonad-cmd workspace-2"
          "switch to workspace 3:xmonad-cmd workspace-3"
          "switch to workspace 4:xmonad-cmd workspace-4"
          "switch to workspace 5:xmonad-cmd workspace-5"
          "switch to workspace 6:xmonad-cmd workspace-6"
          "switch to workspace 7:xmonad-cmd workspace-7"
          "switch to workspace 8:xmonad-cmd workspace-8"
          "switch to workspace 9:xmonad-cmd workspace-9"
          "switch to workspace 10:xmonad-cmd workspace-10"
          "send window to workspace 1:xmonad-cmd send-workspace-1"
          "send window to workspace 2:xmonad-cmd send-workspace-2"
          "send window to workspace 3:xmonad-cmd send-workspace-3"
          "send window to workspace 4:xmonad-cmd send-workspace-4"
          "send window to workspace 5:xmonad-cmd send-workspace-5"
          "send window to workspace 6:xmonad-cmd send-workspace-6"
          "send window to workspace 7:xmonad-cmd send-workspace-7"
          "send window to workspace 8:xmonad-cmd send-workspace-8"
          "send window to workspace 9:xmonad-cmd send-workspace-9"
          "send window to workspace 10:xmonad-cmd send-workspace-10"
          
          # === WINDOW MANAGEMENT ===
          "close window:xmonad-cmd close-window"
          "split window:xmonad-cmd split-window"
          "toggle fullscreen:xmonad-cmd fullscreen"
          "toggle float:xmonad-cmd toggle-float"
          "focus left:xmonad-cmd focus-left"
          "focus right:xmonad-cmd focus-right"
          "focus up:xmonad-cmd focus-up"
          "focus down:xmonad-cmd focus-down"
          "move window left:xmonad-cmd move-left"
          "move window right:xmonad-cmd move-right"
          "move window up:xmonad-cmd move-up"
          "move window down:xmonad-cmd move-down"
          "toggle layout:xmonad-cmd layout-toggle"
          
          # === SYSTEM ===
          "restart xmonad:xmonad-cmd quit-xmonad"
          "lock screen:i3lock -c 000000"
          "suspend:systemctl suspend"
          "shutdown:systemctl poweroff"
          "reboot:systemctl reboot"
          
          # === SCREENSHOTS ===
          "take screenshot:scrot -d 1 ~/screenshot-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
          "screenshot window:scrot -s ~/screenshot-window-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-window-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
          "screenshot area:scrot -s ~/screenshot-area-\$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-area-\$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
          
          # === CLIPBOARD ===
          "copy clipboard:xsel -o | xsel -i -b"
          "paste clipboard:xsel -b | xsel -i"
          "clear clipboard:xsel -c -b"
          
          # === TIME & DATE ===
          "show time:notify-send 'Time' \"\$(date '+%H:%M')\""
          "show date:notify-send 'Date' \"\$(date '+%A, %B %d, %Y')\""
          "show datetime:notify-send 'Date & Time' \"\$(date '+%A, %B %d, %Y at %H:%M')\""
          
          # === DEBUG & TEST ===
          "debug omnibar:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          "test notification:notify-send 'Test' 'This is a test notification'"
          "restart xmobar:pkill xmobar 2>/dev/null || true; sleep 1; xmobar /etc/xmobar/xmobarrc &"
          "debug simple icon test:kitty -e bash -c 'echo \"Simple icon test:\"; echo \"Testing kitty icon lookup...\"; find /nix/store -name \"*kitty*\" -type f 2>/dev/null | grep -E \"\\\\.(png|svg|ico)$\" | head -3; echo \"Testing firefox icon lookup...\"; find /nix/store -name \"*firefox*\" -type f 2>/dev/null | grep -E \"\\\\.(png|svg|ico)$\" | head -3; echo \"Press Enter to close\"; read'"
          "debug omnibar arrays:kitty -e bash -c 'echo \"Debugging omnibar arrays...\"; echo \"All commands:\"; for cmd in \"''${commands[@]}\"; do echo \"  \$cmd\"; done; echo \"Press Enter to close\"; read'"
      )
      
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
