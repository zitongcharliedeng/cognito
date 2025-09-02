
# Get current workspace (with fallback)
current_ws=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk '{print $3}' || echo "0")

# Function to get app icon based on window class (first letter fallback)
get_app_icon() {
    local window_class="$1"
    local window_id="$2"
    
    # Simple fallback: first letter of application class in caps
    local first_char=$(echo "$window_class" | cut -c1 | tr '[:lower:]' '[:upper:]')
    echo "$first_char"
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
                        # Display first letter fallback
                        app_icons="$app_icons<fc=#a0aec0>$icon_result</fc>"
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
