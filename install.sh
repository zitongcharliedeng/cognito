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
  echo "Committing new host configuration to Git (required for flake builds)..."
  # Set temporary Git identity to avoid annoying prompts
  git config user.email "nixos@cognito.local" 2>/dev/null || true
  git config user.name "Cognito NixOS" 2>/dev/null || true
  git add hosts/${HOSTNAME}/
  git commit -m "Add ${HOSTNAME} host configuration" || echo "No changes to commit or already committed"
  echo "Building system configuration..."
  echo "Note: You'll be prompted for your sudo password (same as your NixOS installer password)"
  sudo nixos-rebuild switch --flake .#${HOSTNAME}
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
