
# Function to discover installed applications and find their icons
discover_applications() {
    local apps=()
    
    # Find all installed applications from desktop files (NixOS paths)
    local app_dirs=(
        "/run/current-system/sw/share/applications"
        "/nix/store/*/share/applications"
        "/home/*/.local/share/applications"
    )
    
    for dir in "${app_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' desktop_file; do
                # Skip hidden files
                [[ "$(basename "$desktop_file")" =~ ^\..* ]] && continue
                
                # Extract app info from desktop file
                local name=$(grep "^Name=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                local exec_full=$(grep "^Exec=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                local icon=$(grep "^Icon=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                local no_display=$(grep "^NoDisplay=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                local hidden=$(grep "^Hidden=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                
                # Skip if hidden or no display
                [[ "$no_display" == "true" || "$hidden" == "true" ]] && continue
                
                # Skip if no name or exec
                [[ -z "$name" || -z "$exec_full" ]] && continue
                
                # Clean up exec command (remove %U, %F, etc.) and get first word
                local exec=$(echo "$exec_full" | sed 's/%[a-zA-Z]//g' | xargs | cut -d' ' -f1)
                
                # Find icon in Papirus icon pack (single source of truth)
                local icon_path=""
                if [[ -n "$icon" ]]; then
                    local papirus_icon=$(find /nix/store -path "*/papirus-icon-theme/*/apps/$icon.png" 2>/dev/null | head -1)
                    if [[ -z "$papirus_icon" ]]; then
                        papirus_icon=$(find /nix/store -path "*/papirus-icon-theme/*/apps/$icon.svg" 2>/dev/null | head -1)
                    fi
                    if [[ -n "$papirus_icon" ]]; then
                        icon_path="$papirus_icon"
                    fi
                fi
                
                # Add to apps array
                apps+=("open $name in new window:$exec:$icon_path")
                
            done < <(find "$dir" -name "*.desktop" -print0 2>/dev/null)
        fi
    done
    
    # Remove duplicates and sort
    printf '%s\n' "${apps[@]}" | sort -u
}

# === SIMPLE DIRECT COMMANDS (One Entry Per Action) ===
# Get discovered applications
discovered_apps=($(discover_applications 2>/dev/null || echo ""))

commands=(
    # === APPLICATIONS (Auto-discovered) ===
    "${discovered_apps[@]}"
    
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
    "lock screen:xlock -mode blank"
    "suspend:systemctl suspend"
    "shutdown:systemctl poweroff"
    "reboot:systemctl reboot"
    
    # === SCREENSHOTS ===
    "take screenshot:scrot -d 1 /tmp/screenshot-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
    "screenshot window:scrot -s /tmp/screenshot-window-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
    "screenshot area:scrot -s /tmp/screenshot-area-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
    
    # === CLIPBOARD ===
    "copy clipboard:xsel -o | xsel -i -b"
    "paste clipboard:xsel -b | xsel -i"
    "clear clipboard:xsel -c -b"
    
    # === TIME & DATE ===
    "show time:notify-send 'Time' \"$(date '+%H:%M')\""
    "show date:notify-send 'Date' \"$(date '+%A, %B %d, %Y')\""
    "show datetime:notify-send 'Date & Time' \"$(date '+%A, %B %d, %Y at %H:%M')\""
    
    # === DEBUG & TEST ===
    "debug omnibar:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
    "test notification:notify-send 'Test' 'This is a test notification'"
    "restart xmobar:pkill xmobar 2>/dev/null || true; sleep 1; xmobar /etc/xmobar/xmobarrc &"
    "debug omnibar script:kitty -e bash -c 'echo \"Testing omnibar script...\"; echo \"Script location:\"; which cognito-omnibar; echo \"Script syntax:\"; bash -n /nix/store/*/bin/cognito-omnibar 2>&1 || echo \"Syntax check failed\"; echo \"Press Enter to close\"; read'"
    "debug discovered apps:kitty -e bash -c 'echo \"Discovered applications:\"; discover_applications | head -10; echo \"Press Enter to close\"; read'"
)

# Show commands with rofi
if command -v rofi >/dev/null 2>&1; then
    # Create a temporary file for rofi with icons
    rofi_input=$(mktemp)
    
    # Process commands and add icons where possible
    for cmd in "${commands[@]}"; do
        display_name=$(echo "$cmd" | cut -d: -f1)
        exec_cmd=$(echo "$cmd" | cut -d: -f2)
        icon_path=$(echo "$cmd" | cut -d: -f3)
        
        # Use icon if available, otherwise no icon
        if [[ -n "$icon_path" && -f "$icon_path" ]]; then
            echo "$icon_path	$display_name" >> "$rofi_input"
        else
            echo "	$display_name" >> "$rofi_input"
        fi
    done
    
    input=$(rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 60 -lines 20 < "$rofi_input" | cut -f2-)
    rm -f "$rofi_input"
    
    if [[ -n "$input" ]]; then
        # Find the original command from our commands array
        cmd=""
        for original_cmd in "${commands[@]}"; do
            # Handle both old format (2 fields) and new format (3 fields)
            cmd_display=$(echo "$original_cmd" | cut -d: -f1)
            if [[ "$cmd_display" == "$input" ]]; then
                cmd=$(echo "$original_cmd" | cut -d: -f2)
                break
            fi
        done
        
        if [[ -n "$cmd" ]]; then
            echo "Executing: $cmd"
            # Log to a file for debugging
            echo "$(date): Executing command: $cmd" >> /tmp/cognito-omnibar.log
            # Execute command directly in current shell context
            eval "$cmd" &
        else
            echo "Command not found for: $input"
        fi
    fi
else
    echo "Rofi not found"
fi
