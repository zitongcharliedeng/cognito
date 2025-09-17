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

# Function to display action selection menu
select_action() {
    echo -e "${BOLD}Available actions:${NC}"
    echo ""
    echo "  1. Build configuration (compile only)"
    echo "  2. Build and switch configuration (configuration applied after reboot)"
    echo "  3. Build, switch, and auto-reboot to new configuration"
    echo "  4. Test configuration (dry run)"
    echo "  5. Regenerate hardware configuration"
    echo "  6. List available devices"
    echo "  7. Exit"
    echo ""
    
    while true; do
        read -p "Select action (1-7): " choice
        case "$choice" in
            1)
                selected_action="build"
                break
                ;;
            2)
                selected_action="switch"
                break
                ;;
            3)
                selected_action="switch-reboot"
                break
                ;;
            4)
                selected_action="test"
                break
                ;;
            5)
                selected_action="regenerate"
                break
                ;;
            6)
                selected_action="list"
                break
                ;;
            7)
                selected_action="exit"
                break
                ;;
            *)
                print_error "Invalid selection. Please enter a number between 1 and 7"
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
        "switch-reboot")
            print_status "Building and switching to configuration for device: $device"
            nixos-rebuild switch --flake ".#$device"
            print_success "Successfully switched to configuration for $device"
            echo ""
            print_warning "The system will reboot in 10 seconds to apply the new configuration."
            print_warning "Press Ctrl+C to cancel the reboot."
            echo ""
            sleep 10
            print_status "Rebooting system..."
            sudo reboot
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
        # Select device
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
        
        # Select action
        select_action
        
        # Execute action
        execute_action "$selected_device" "$selected_action"
        
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
