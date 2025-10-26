#!/bin/bash
# Cognito OS Interactive Build Script
# Usage: ./build.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BOLD}${CYAN}================================${NC}"
    echo -e "${BOLD}${CYAN}    Cognito OS Build Manager    ${NC}"
    echo -e "${BOLD}${CYAN}================================${NC}"
    echo ""
}

# Function to get available devices
get_devices() {
    local devices=()
    if [ -d "./system-hardware-shims" ]; then
        for device in ./system-hardware-shims/*/; do
            if [ -d "$device" ]; then
                device_name=$(basename "$device")
                devices+=("$device_name")
            fi
        done
    fi
    echo "${devices[@]}"
}

# Function to check if device exists
check_device() {
    local device=$1
    if [ ! -d "./system-hardware-shims/$device" ]; then
        print_error "Device '$device' not found in system-hardware-shims/"
        return 1
    fi
    return 0
}

# Function to check if required files exist
check_device_files() {
    local device=$1
    local device_dir="./system-hardware-shims/$device"
    
    if [ ! -f "$device_dir/hardware-configuration.nix" ]; then
        print_error "hardware-configuration.nix not found for device '$device'"
        return 1
    fi
    
    if [ ! -f "$device_dir/firmware-configuration.nix" ]; then
        print_error "firmware-configuration.nix not found for device '$device'"
        return 1
    fi
    
    return 0
}

# Function to display device selection menu
select_device() {
    local devices=($(get_devices))
    
    if [ ${#devices[@]} -eq 0 ]; then
        print_warning "No devices found in system-hardware-shims/"
        print_status "Please create a device folder first."
        return 1
    fi
    
    echo -e "${BOLD}Available devices:${NC}"
    echo ""
    for i in "${!devices[@]}"; do
        echo "  $((i+1)). ${devices[i]}"
    done
    echo ""
    
    while true; do
        read -p "Select device (1-${#devices[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#devices[@]}" ]; then
            selected_device="${devices[$((choice-1))]}"
            break
        else
            print_error "Invalid selection. Please enter a number between 1 and ${#devices[@]}"
        fi
    done
    
    echo ""
    print_status "Selected device: $selected_device"
    return 0
}

# Function to perform first-time installation setup
first_time_install() {
    echo -e "${BOLD}First-Time Installation Setup${NC}"
    echo ""
    print_status "This will move GLFOS generated hardware configs to system-hardware-shims/"
    echo ""
    
    # Ask for device name
    while true; do
        read -p "Enter device name (e.g., my-laptop, my-desktop): " device_name
        if [ -z "$device_name" ]; then
            print_error "Device name cannot be empty"
            continue
        fi
        if [ -d "./system-hardware-shims/$device_name" ]; then
            print_error "Device '$device_name' already exists in system-hardware-shims/"
            read -p "Do you want to overwrite it? (y/N): " overwrite
            if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        break
    done
    
    echo ""
    print_status "Setting up device: $device_name"
    
    # Check if source files exist
    if [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
        print_error "/etc/nixos/hardware-configuration.nix not found"
        print_error "Please run GLFOS installer first to generate hardware configs"
        return 1
    fi
    
    if [ ! -f "/etc/nixos/configuration.nix" ]; then
        print_error "/etc/nixos/configuration.nix not found"
        print_error "Please run GLFOS installer first to generate firmware configs"
        return 1
    fi
    
    # Create device folder
    print_status "Creating device folder: system-hardware-shims/$device_name/"
    mkdir -p "./system-hardware-shims/$device_name"
    
    # Copy and clean hardware-configuration.nix
    print_status "Moving hardware-configuration.nix..."
    sudo cp /etc/nixos/hardware-configuration.nix "./system-hardware-shims/$device_name/hardware-configuration.nix"
    sudo chown $USER:$USER "./system-hardware-shims/$device_name/hardware-configuration.nix"
    
    # Remove glf.environment lines from hardware-configuration.nix
    sed -i '/glf\.environment\.type/d' "./system-hardware-shims/$device_name/hardware-configuration.nix"
    sed -i '/glf\.environment\.edition/d' "./system-hardware-shims/$device_name/hardware-configuration.nix"
    
    # Copy and clean configuration.nix -> firmware-configuration.nix
    print_status "Moving configuration.nix as firmware-configuration.nix..."
    sudo cp /etc/nixos/configuration.nix "./system-hardware-shims/$device_name/firmware-configuration.nix"
    sudo chown $USER:$USER "./system-hardware-shims/$device_name/firmware-configuration.nix"
    
    print_status "Cleaning up unneeded GLF-OS auto-generated lines..."
    sed -i '/glf\.environment\.type/d' "./system-hardware-shims/$device_name/firmware-configuration.nix"
    sed -i '/glf\.environment\.edition/d' "./system-hardware-shims/$device_name/firmware-configuration.nix"
    sed -i '/\.\/hardware-configuration\.nix/d' "./system-hardware-shims/$device_name/firmware-configuration.nix"
    sed -i '/\.\/customConfig/d' "./system-hardware-shims/$device_name/firmware-configuration.nix"
    
    # Extract username from users.users.<username> line
    print_status "Extracting username from configuration..."
    local username=$(grep -oP 'users\.users\.\K[^.=\s{]+' "./system-hardware-shims/$device_name/firmware-configuration.nix" | head -1)
    
    if [ -z "$username" ]; then
        print_error "Could not find username in configuration file"
        print_error "Expected to find 'users.users.<username>' in firmware-configuration.nix"
        return 1
    fi
    
    print_status "Found username: $username"
    
    # Add username module export right before users.users line
    print_status "Adding username module export..."
    sed -i "/users\.users\./i\  # Export default username as a special argument for other modules\n  _module.args.defaultUsername = \"$username\";\n" "./system-hardware-shims/$device_name/firmware-configuration.nix"
    
    # Stage changes in git so they can be used for building
    print_status "Staging changes in git..."
    git add .
    
    echo ""
    print_success "Device '$device_name' has been set up successfully!"
    print_status "Files created:"
    print_status "  - system-hardware-shims/$device_name/hardware-configuration.nix"
    print_status "  - system-hardware-shims/$device_name/firmware-configuration.nix"
    echo ""
    print_status "The device will be automatically detected by flake.nix"
    print_status "You can now build with: ./build.sh"
    echo ""
    
    return 0
}

# Function to display action selection menu
select_action() {
    echo -e "${BOLD}Available actions:${NC}"
    echo ""
    echo "  0. First-time installation (setup new device from GLFOS generated configs)"
    echo "  1. Build configuration (compile only)"
    echo "  2. Build and switch to new configuration (some on-start services may need a reboot after to start)"
    echo "  3. Test configuration (dry run)"
    echo "  4. Regenerate hardware configuration"
    echo "  5. List available devices"
    echo "  6. Exit"
    echo ""
    
    while true; do
        read -p "Select action (0-6): " choice
        case "$choice" in
            0)
                selected_action="first-time-install"
                break
                ;;
            1)
                selected_action="build"
                break
                ;;
            2)
                selected_action="switch"
                break
                ;;
            3)
                selected_action="test"
                break
                ;;
            4)
                selected_action="regenerate"
                break
                ;;
            5)
                selected_action="list"
                break
                ;;
            6)
                selected_action="exit"
                break
                ;;
            *)
                print_error "Invalid selection. Please enter a number between 0 and 6"
                ;;
        esac
    done
    
    echo ""
    return 0
}

# Function to execute the selected action
execute_action() {
    local device=$1
    local action=$2

    case "$action" in
        "first-time-install")
            first_time_install
            ;;
        "build")
            print_status "Building configuration for device: $device"
            nixos-rebuild build --flake ".#$device"
            print_success "Configuration built successfully for $device"
            ;;
        "switch")
            print_status "Building and switching to configuration for device: $device"
            nixos-rebuild switch --flake ".#$device"
            print_success "Successfully switched to configuration for $device"
            ;;
        "test")
            print_status "Testing configuration for device: $device"
            nixos-rebuild test --flake ".#$device"
            print_success "Configuration test passed for $device"
            ;;
        "regenerate")
            print_status "Regenerating hardware configuration for device: $device"
            echo ""
            print_warning "This will regenerate the hardware-configuration.nix file for $device"
            print_warning "Make sure you have the correct hardware connected before proceeding."
            echo ""
            read -p "Continue with hardware regeneration? (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                print_status "Running nixos-generate-config for $device..."
                sudo nixos-generate-config --dir ./system-hardware-shims/$device/
                print_success "Hardware configuration regenerated for $device"
                echo ""
                print_warning "IMPORTANT: For firmware configuration changes (NVIDIA, bootloader, etc.),"
                print_warning "consider running a fresh GLFOS installer to get updated firmware shims."
                print_warning "The installer will generate both hardware-configuration.nix and firmware-configuration.nix"
                print_warning "with the latest GLF optimizations for your hardware."
            else
                print_status "Hardware regeneration cancelled."
            fi
            ;;
        "list")
            print_status "Available devices:"
            local devices=($(get_devices))
            for device in "${devices[@]}"; do
                echo "  - $device"
            done
            ;;
        "exit")
            print_status "Goodbye!"
            exit 0
            ;;
    esac
}

# Main interactive function
main() {
    print_header
    
    while true; do
        # Select action first
        select_action
        
        # For first-time install, skip device selection
        if [ "$selected_action" = "first-time-install" ]; then
            execute_action "" "$selected_action"
        elif [ "$selected_action" = "list" ] || [ "$selected_action" = "exit" ]; then
            # List and exit don't need device selection either
            execute_action "" "$selected_action"
        else
            # Select device for other actions
            if ! select_device; then
                break
            fi
            
            # Check device and files
            if ! check_device "$selected_device"; then
                break
            fi
            
            if ! check_device_files "$selected_device"; then
                break
            fi
            
            # Execute action
            execute_action "$selected_device" "$selected_action"
        fi
        
        # Break if exit was selected
        if [ "$selected_action" = "exit" ]; then
            break
        fi
        
        echo ""
        echo -e "${BOLD}${CYAN}================================${NC}"
        echo ""
        
        # Ask if user wants to continue
        read -p "Do you want to perform another action? (y/N): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            print_status "Goodbye!"
            break
        fi
        echo ""
    done
}

# Run main function
main
