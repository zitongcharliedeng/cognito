#!/usr/bin/env bash
set -euo pipefail

# Path to your repo — use current directory for flake-based setup
REPO_PATH="$(pwd)"

print_header() {
  echo "=== Cognito Installer ==="
  echo "This will set up a new host or reuse an existing one."
  echo
}

setup_sudo_once() {
  # Read sudo password once and use askpass for non-interactive sudo later
  echo -n "[sudo] password for $(whoami): "
  stty -echo
  read -r SUDO_PW
  stty echo
  echo
  ASKPASS_SCRIPT=$(mktemp)
  chmod 700 "$ASKPASS_SCRIPT"
  printf '#!/usr/bin/env bash\necho "%s"\n' "$SUDO_PW" > "$ASKPASS_SCRIPT"
  unset SUDO_PW
  export SUDO_ASKPASS="$ASKPASS_SCRIPT"
  trap 'shred -u "$ASKPASS_SCRIPT" 2>/dev/null || rm -f "$ASKPASS_SCRIPT"' EXIT
}

list_hosts() {
  echo "Existing hardware shims:"
  ls -1 "$REPO_PATH/system-hardware-shims" || echo "(none yet)"
  echo
}

get_host() {
  while true; do
    echo -n "Enter hostname for this device to "use existing or create new" hardware-shim so Cognito is compatible with it i.e. my-dying-thinkpad-laptop. Note that the device must support 3D hardware acceleration, since Cognito is a Wayland-first OS. Most devices in the last decade - phone, laptop, desktop - should support this. "
    read -r HOSTNAME
    
    # Validate hostname is not empty
    if [[ -z "$HOSTNAME" ]]; then
      echo "❌ Hostname cannot be empty. Please enter a valid hostname."
      continue
    fi
    
    # Validate hostname contains only valid characters (alphanumeric, hyphens, underscores)
    if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      echo "❌ Hostname can only contain letters, numbers, hyphens, and underscores."
      continue
    fi
    
    # Validate hostname doesn't start or end with hyphen
    if [[ "$HOSTNAME" =~ ^-|-$ ]]; then
      echo "❌ Hostname cannot start or end with a hyphen."
      continue
    fi
    
    echo "✔ Using hostname: $HOSTNAME"
    break
  done
}

create_host_dir() {
  HOST_DIR="$REPO_PATH/system-hardware-shims/$HOSTNAME"
  
  # Create directory if it doesn't exist
  if [[ ! -d "$HOST_DIR" ]]; then
    echo "Creating new host directory at $HOST_DIR"
    mkdir -p "$HOST_DIR"
  else
    echo "✔ Host $HOSTNAME directory already exists"
  fi

  # Check if hardware configuration exists, copy if needed
  if [[ ! -f "$HOST_DIR/hardware-configuration.nix" ]]; then
    if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
      echo "❌ Couldn't find /etc/nixos/hardware-configuration.nix"
      echo "Have you installed NixOS on this machine yet?"
      echo "Run 'sudo nixos-generate-config' to generate the hardware configuration in-case it was deleted."
      exit 1
    fi
    cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
    echo "✔ Copied hardware-configuration.nix"
  else
    echo "✔ Hardware configuration already exists"
  fi

  # Create or update configuration.nix
  if [[ ! -f "$HOST_DIR/configuration.nix" ]]; then
    cat > "$HOST_DIR/configuration.nix" <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Hostname ties this config to the device
  networking.hostName = "${HOSTNAME}";

  # Bootloader configuration (hardware agnostic)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";  # Hardware agnostic - will be auto-detected or set by hardware-configuration.nix

  # ⚠️ If you need device-specific quirks (e.g. mic LED fix),
  # put them here — NOT in hardware-configuration.nix.
  # 
  # Note: System-agnostic features (SSH, X server, basic packages, users)
  # are automatically included via the flake.nix configuration.

  system.stateVersion = "23.11";
}
EOF
    echo "✔ Created minimal configuration.nix for $HOSTNAME"
  else
    echo "✔ Configuration.nix already exists"
  fi
}

build_system() {
  echo "Building system for host $HOSTNAME..."
  echo "Running from directory: $(pwd)"
  
  # Check if flake.nix exists in current directory otherwise nixos-rebuild will not use this repo's configs
  if [[ ! -f "flake.nix" ]]; then
    echo "❌ flake.nix not found in current directory"
    echo "Please run this script from the root of your cognito repository"
    exit 1
  fi
  
  # Test that this NixOS version can use flake evaluation first
  echo "Testing flake configuration..."
  nix flake show --extra-experimental-features "nix-command flakes" 2>/dev/null || {
    echo "❌ Flake evaluation failed."
    echo "Flakes may not be enabled on this NixOS system."
    echo "To enable flakes, add this to /etc/nixos/configuration.nix:"
    echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
    echo "Then run: sudo nixos-rebuild switch"
    exit 1
  }
  
  echo "Building system..."
  echo "Committing new hardware shim configuration to Git (required for flake builds)..."
  # Set temporary Git identity to avoid annoying prompts
  git config user.email "nixos@cognito.local" 2>/dev/null || true
  git config user.name "Cognito NixOS" 2>/dev/null || true
  git add system-hardware-shims/${HOSTNAME}/
  git commit -m "Add ${HOSTNAME} hardware shim configuration" || echo "No changes to commit or already committed"
  echo "Building system configuration..."
  # Prompt once right before the long build, then keep sudo alive
  if sudo -A sh -c "nixos-rebuild switch --flake .#${HOSTNAME} && systemctl reboot"; then
    echo "✔ Done. Reboot recommended to apply kernel/bootloader changes."
    echo "System is rebooting now..."
  else
    echo "❌ nixos-rebuild failed. Not rebooting."
    exit 1
  fi
}

main() {
  print_header
  list_hosts
  get_host
  create_host_dir
  setup_sudo_once
  build_system
}

main
