
get_app_icon() {
    local app_name="$1"
    local test_mode="$2"
    
    # Search for icons in Nix store and system paths
    local icon_paths=(
        "/nix/store"
        "/run/current-system/sw/share"
        "/usr/share"
    )
    
    for base_path in "${icon_paths[@]}"; do
        local icon_file=$(find "$base_path" -path "*/icons/*" -name "*$app_name*" -type f 2>/dev/null | grep -E '\.(png|svg|ico)$' | head -1)
        if [[ -n "$icon_file" ]]; then
            if [[ "$test_mode" == "test" ]]; then
                echo "Found icon: $icon_file"
            fi
            # Extract first letter from filename for xmobar display
            local first_letter=$(basename "$icon_file" | cut -c1 | tr '[:lower:]' '[:upper:]')
            echo "$first_letter"
            return 0
        fi
    done
    
    # Fallback to first letter of app name
    local first_letter=$(echo "$app_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
    echo "$first_letter"
}

# Get current workspace
current_ws=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')

# Build workspace preview
preview=""
for i in {1..10}; do
    if [[ $i -eq $((current_ws + 1)) ]]; then
        preview+="[$i]"
    else
        preview+=" $i "
    fi
done

echo "$preview"
