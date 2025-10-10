{ config, pkgs, lib, ... }:

let
  # Make sure this folder exists and contains your .jar mods.
  localModsPath = ./vendor/mods;

  # ---- one fetched dep: Fabric API for MC 1.21.5 ----
  fabricApi = pkgs.fetchurl {
    # Modrinth CDN (works with MC 1.21.5)
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/MNJwZRWx/fabric-api-0.119.5%2B1.21.5.jar";
    sha256 = "sha256-xBdqOp2twkORdJpvjb5DzaaVA+gRPbcaiIDY2bQJ/J8=";
  };

  # ---- build a FLAT mods/ dir (no subfolders) ----
  modsDir = pkgs.runCommandNoCC "mods-flat" { } ''
    set -eu
    mkdir -p "$out"

    # Add fabric-api jar
    cp ${fabricApi} "$out/"

    # Add all local jars directly at top-level
    # (no shopt, just find)
    if [ -d ${localModsPath} ]; then
      find ${localModsPath} -maxdepth 1 -type f -name '*.jar' -print0 \
        | xargs -0 -I{} cp "{}" "$out/"
    fi
  '';
in
{ 
  programs.tmux.enable = true;
  # ^ In order to run the admin console and run opless commands like: sudo -u minecraft tmux -S /run/minecraft/sharedsurvival.sock attach
  # Share ip with friends using Tailnet instead of port forwarding
  services.tailscale.enable = true;
  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/mc-sharedsurvival";

    servers.sharedsurvival = {
      enable = true;

      # These mods require Fabric on MC 1.21.5
      package = pkgs.fabricServers.fabric-1_21_5;

      # Present the flat mods/ directory to the server
      symlinks = {
        "mods" = modsDir;
        # If you have server configs to pin, uncomment and point at a folder:
        # "config" = ./vendor/config;
      };

      serverProperties = {
        motd = "Shared Chained Survival (NixOS)";
        online-mode = true;
        "max-players" = 10;
      };

      jvmOpts = "-Xms6G -Xmx6G";
      openFirewall = true;
    };
  };
}
