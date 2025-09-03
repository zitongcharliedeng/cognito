#!/usr/bin/env bash

# Custom rofi mode for custom actions (workspace, window management, etc.)
# This script outputs commands for rofi to display

# Custom commands
commands=(
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
    
    "restart xmonad:xmonad-cmd quit-xmonad"
    "lock screen:loginctl lock-session"
    "suspend:systemctl suspend"
    "shutdown:systemctl poweroff"
    "reboot:systemctl reboot"
    
    "take screenshot:scrot -d 1 /tmp/screenshot-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
    "screenshot window:scrot -s /tmp/screenshot-window-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
    "screenshot area:scrot -s /tmp/screenshot-area-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < /tmp/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
    
    "copy clipboard:xsel -o | xsel -i -b"
    "paste clipboard:xsel -b | xsel -i"
    "clear clipboard:xsel -c -b"
    
    "show time:notify-send 'Time' \"$(date '+%H:%M')\""
    "show date:notify-send 'Date' \"$(date '+%A, %B %d, %Y')\""
    "show datetime:notify-send 'Date & Time' \"$(date '+%A, %B %d, %Y at %H:%M')\""
    
    "debug omnibar:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
    "test notification:notify-send 'Test' 'This is a test notification'"
    "restart xmobar:pkill xmobar 2>/dev/null || true; sleep 1; xmobar /etc/xmobar/xmobarrc &"
    "debug omnibar script:kitty -e bash -c 'echo \"Testing omnibar script...\"; echo \"Script location:\"; which cognito-omnibar; echo \"Script syntax:\"; bash -n /nix/store/*/bin/cognito-omnibar 2>&1 || echo \"Syntax check failed\"; echo \"Press Enter to close\"; read'"
)

# Output commands for rofi
for cmd in "${commands[@]}"; do
    display_name=$(echo "$cmd" | cut -d: -f1)
    echo "$display_name"
done
