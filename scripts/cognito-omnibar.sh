#!/bin/bash

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
    "take screenshot:scrot -d 1 ~/screenshot-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
    "screenshot window:scrot -s ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
    "screenshot area:scrot -s ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
    
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
    "debug simple icon test:kitty -e bash -c 'echo \"Simple icon test:\"; echo \"Testing kitty icon lookup...\"; find /nix/store -name \"*kitty*\" -type f 2>/dev/null | grep -E \"\\\\.(png|svg|ico)$\" | head -3; echo \"Testing firefox icon lookup...\"; find /nix/store -name \"*firefox*\" -type f 2>/dev/null | grep -E \"\\\\.(png|svg|ico)$\" | head -3; echo \"Press Enter to close\"; read'"
    "debug omnibar arrays:kitty -e bash -c 'echo \"Debugging omnibar arrays...\"; echo \"All commands:\"; for cmd in \"${commands[@]}\"; do echo \"  \$cmd\"; done; echo \"Press Enter to close\"; read'"
)

# Show commands with rofi
if command -v rofi >/dev/null 2>&1; then
    input=$(printf '%s\n' "${commands[@]}" | rofi -i -p "🔍 Cognito Omnibar" -width 60 -lines 20)
    
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
