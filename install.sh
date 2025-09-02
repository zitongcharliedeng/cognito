#!/usr/bin/env bash
set -euo pipefail

# Path to your repo — change this if your repo lives elsewhere
REPO_PATH="/etc/nixos"

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
  if [[ -d "$HOST_DIR" ]]; then
    echo "✔ Host $HOSTNAME already exists, using it."
  else
    echo "Creating new host directory at $HOST_DIR"
    mkdir -p "$HOST_DIR"

    if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
      echo "❌ Couldn’t find /etc/nixos/hardware-configuration.nix"
      echo "Have you installed NixOS on this machine yet?"
      exit 1
    fi

    cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"

    # create a minimal configuration.nix for this host
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
}
EOF
    echo "✔ Created minimal configuration.nix for $HOSTNAME"
  fi
}

build_system() {
  echo "Building system for host $HOSTNAME..."
  sudo nixos-rebuild switch --flake "$REPO_PATH#$HOSTNAME"
  echo "✔ Done. Reboot recommended to apply kernel/bootloader changes."
}

main() {
  print_header
  list_hosts
  get_host
  create_host_dir
  build_system
}

main
