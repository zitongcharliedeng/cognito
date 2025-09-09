{ config, pkgs, lib, ... }:
let
  hyprStart = pkgs.writeShellScriptBin "hyprland-start" ''
    #!/bin/sh
    CONFIG_PATH=/etc/hypr/hyprland.conf
    if systemd-detect-virt --quiet; then
      export WLR_RENDERER=pixman
    fi
    exec Hyprland -c "$CONFIG_PATH"
  '';
in
{
  options = {
    cognito.hyprland.startCmd = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Command to start Hyprland session with VM-safe renderer selection.";
    };
  };

  config = {
    # Hyprland session launcher with VM-safe renderer selection.
    # In VMs, virgl/virtio 3D can stall wlroots compositors (random freezes).
    # Use pixman only when virtualized; keep GPU acceleration on bare metal.
    environment.systemPackages = [ hyprStart ];
    cognito.hyprland.startCmd = "${hyprStart}/bin/hyprland-start";
  };
}


