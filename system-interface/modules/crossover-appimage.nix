{ config, pkgs, lib, ... }:

let
  # Upstream release details
  version = "3.3.4";
  url = "https://github.com/lacymorrow/crossover/releases/download/v${version}/CrossOver-${version}-x86_64.AppImage";
  sha256 = "0hczjy1aci635a24imgs7ckbdqsvfpbmgi1nhlh0pb0y8ryjkm5b";

  app = pkgs.appimageTools.wrapType2 {
    inherit version;
    pname = "crossover";
    src = pkgs.fetchurl { url = url; sha256 = sha256; };
    extraPkgs = pkgs: [ ];
    extraInstallCommands = ''
      mkdir -p $out/bin $out/share/applications
      cat > $out/bin/crossover-crosshair <<'EOF'
      #!/usr/bin/env bash
        set -euo pipefail

        # Auto-select flags for Wayland vs X11
        FLAGS=("--no-sandbox")
        # if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        #   export ELECTRON_OZONE_PLATFORM_HINT=wayland
        #   # Wayland: keep GPU on for proper transparency
        # else
        #   export ELECTRON_OZONE_PLATFORM_HINT=x11
        #   export LIBGL_ALWAYS_SOFTWARE=1
        #   FLAGS+=("--disable-gpu" "--disable-gpu-compositing" "--enable-transparent-visuals")
        # fi

        exec "$(dirname "$0")/crossover" "${FLAGS[@]}" "$@"
      EOF
            chmod +x $out/bin/crossover-crosshair

            cat > $out/share/applications/crossover-crosshair.desktop <<'EOF'
      [Desktop Entry]
      Name=CrossOver (Crosshair)
      Exec=crossover-crosshair
      Type=Application
      Terminal=false
      Categories=Utility;
      EOF
    '';
  };
in
{
  options.crossover = {
    enable = lib.mkEnableOption "Enable CrossOver AppImage";
  };

  config = lib.mkIf config.crossover.enable {
    environment.systemPackages = [ app ];
  };
}


