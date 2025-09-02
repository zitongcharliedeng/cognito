#!/usr/bin/env bash
set -euo pipefail

# Path to your repo — use current directory for flake-based setup
REPO_PATH="$(pwd)"

# TODO rename hosts to be hardware-shims
print_header() {
  echo "=== Cognito Installer ==="
  echo "This will set up a new host or reuse an existing one."
  echo
}

list_hosts() {
  echo "Existing hosts:"
  ls -1 "$REPO_PATH/hosts" || echo "(none yet)"
  echo
}

get_host() {
  echo -n "Enter hostname for hardware-shim (existing or create new): "
  read -r HOSTNAME
}

create_host_dir() {
  HOST_DIR="$REPO_PATH/hosts/$HOSTNAME"
  
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
    echo "This could be because:"
    echo "  1. Flakes are not enabled on this NixOS system"
    echo "  2. Your flake.nix has syntax errors"
    echo "  3. Experimental features are disabled"
    echo ""
    echo "To enable flakes permanently, add this to your /etc/nixos/configuration.nix:"
    echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
    exit 1
  }
  
  echo "Building system..."
  echo "Debug: Attempting to build host: ${HOSTNAME}"
  echo "Debug: Available hosts in flake:"
  nix flake show --extra-experimental-features "nix-command flakes" | grep -A 10 "nixosConfigurations" || echo "No nixosConfigurations found"
  echo ""
  echo "Debug: Committing new host configuration to Git..."
  git add hosts/${HOSTNAME}/
  git commit -m "Add ${HOSTNAME} host configuration" || echo "No changes to commit or already committed"
  
  echo "Debug: Running nixos-rebuild with verbose output..."
  sudo nixos-rebuild switch --flake .#${HOSTNAME} --verbose
  echo "✔ Done. Reboot recommended to apply kernel/bootloader changes."
  echo "Note: Your flake configuration is now active. Future changes should be made in this repository."
}

main() {
  print_header
  list_hosts
  get_host
  create_host_dir
  build_system
}

main
