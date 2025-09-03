
#!/usr/bin/env bash
# Cognito Omnibar - Unified command center using rofi

# Show commands with rofi
if command -v rofi >/dev/null 2>&1; then
    # Use rofi's combi mode to show custom commands and applications together
    rofi -show combi -modi combi -combi-modi "custom-actions-mode,run,drun" -p "🔍 Cognito Omnibar"
else
    echo "Rofi not found"
fi
