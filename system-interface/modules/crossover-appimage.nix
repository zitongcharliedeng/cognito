{ config, pkgs, lib, ... }:

let
  # Upstream release details
  version = "3.1.5";
  url = "https://github.com/lacymorrow/crossover/releases/download/v${version}/CrossOver-${version}-x86_64.AppImage";
  sha256 = "0c7wj364pdyfr4n0fmk51lzkip8nily0jzmhsihz5m17bxm4z17b";

  app = pkgs.appimageTools.wrapType2 {
    inherit version;
    pname = "crossover";
    src = pkgs.fetchurl { url = url; sha256 = sha256; };
    extraPkgs = pkgs: [ ];
  };

  # Install wrapper script inline for clarity/maintainability
  wrapper = pkgs.writeShellScriptBin "crossover-crosshair" ''
    #!/usr/bin/env bash
    #
    # CrossOver Crosshair launcher
    # - Always launch with --no-sandbox to avoid black background issue on KDE6
    # - See: https://github.com/lacymorrow/crossover/issues/302

    set -euo pipefail

    exec crossover --no-sandbox "$@"
'';

  # Desktop entry for the wrapper
  desktopItem = pkgs.makeDesktopItem {
    name = "crossover-crosshair";
    desktopName = "CrossOver (Crosshair)";
    exec = "crossover-crosshair";
    terminal = false;
    categories = [ "Utility" ];
  };
in
{
  options.crossover = {
    enable = lib.mkEnableOption "Enable CrossOver AppImage";
  };

  config = lib.mkIf config.crossover.enable {
    environment.systemPackages = [ app wrapper desktopItem ];
  };
}
