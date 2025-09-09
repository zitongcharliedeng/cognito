{ config, pkgs, lib, ... }:
let
  hyprStart = pkgs.writeShellScriptBin "hyprland-start" ''
    #!/bin/sh
    CONFIG_PATH=/etc/hypr/hyprland.conf
    if systemd-detect-virt --quiet; then
      export WLR_RENDERER=pixman
      export HYPR_VM_PIXMAN=1
    fi
    exec Hyprland -c "$CONFIG_PATH"
  '';
in
{
  # Hyprland session launcher with VM-safe renderer selection.
  # In VMs, virgl/virtio 3D can stall wlroots compositors (random freezes).
  # Use pixman only when virtualized; keep GPU acceleration on bare metal.
  environment.systemPackages = [ hyprStart ];
  options.cognito.hyprland.startCmd = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    description = "Command to start Hyprland session with VM-safe renderer selection.";
  };
  config.cognito.hyprland.startCmd = "${hyprStart}/bin/hyprland-start";
}


