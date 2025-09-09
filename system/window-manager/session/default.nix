{ config, pkgs, lib, ... }:
let
  hyprStart = pkgs.writeShellScriptBin "hyprland-start" ''
    #!/bin/sh
    CONFIG_PATH=/etc/hypr/hyprland.conf
    # Optional per-user override: ~/.config/cognito/renderer (pixman|gl)
    OVERRIDE="$HOME/.config/cognito/renderer"
    if [ -f "$OVERRIDE" ]; then
      R=$(cat "$OVERRIDE" | tr -d '\n' )
      if [ "$R" = "pixman" ] || [ "$R" = "gl" ]; then
        export WLR_RENDERER="$R"
      fi
    else
      if systemd-detect-virt --quiet; then
        export WLR_RENDERER=pixman
      fi
    fi
    exec Hyprland -c "$CONFIG_PATH"
  '';
  wallpaperCandidates = [
    ../assets/wallpapers/wallpaper.png
    ../assets/wallpapers/wallpaper.jpg
    ../assets/wallpapers/wallpaper.jpeg
  ];
  chosenWallpapers = builtins.filter (p: builtins.pathExists p) wallpaperCandidates;
  wallpaperPath = if chosenWallpapers == [] then ./assets/wallpapers/wallpaper.png else builtins.head chosenWallpapers;
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

    # Create Hyprland session target for systemd user services
  systemd.user.targets.hyprland-session = {
    description = "Hyprland session";
    unitConfig = {
      StopWhenUnneeded = false;
    };
  };


  # Hyprpaper wallpaper config; replace the path with your PNG if desired
  environment.etc."hypr/hyprpaper.conf".text = ''
  preload = ${wallpaperPath}
  wallpaper = ,${wallpaperPath}
  ipc = off
  '';
}
