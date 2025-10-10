{ config, pkgs, ... }:

{
  # --- Minecraft server declarative configuration ---
  services.minecraft-servers = {
    enable = true;
    eula = true;
    # All worlds/configs live here (persistent)
    dataDir = "/var/lib/mc-sharedsurvival";
    
    # Define one server
    servers.sharedsurvival = {
      enable = true;

      # Choose the right loader for the pack (likely Fabric/NeoForge).
      # If the pack is Fabric on MC 1.21.x, use:
      package = pkgs.fabricServers.fabric-1_21_1;
      # If it's NeoForge/Forge, switch to the matching package, e.g.:
      # package = pkgs.neoforgeServers.neoforge-1_21_1;

      # Pull the mod list via Packwiz (pure, reproducible)
      symlinks =
        let
          modpack = pkgs.fetchPackwizModpack {
            # Local file URL to your pack.toml:
            url = "file:///home/zitchaden/packs/shared-survival/pack.toml";
            # Temporary dummy; will replace with the real hash after the first build:
            packHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        in {
          "mods" = "${modpack}/mods";
          "config" = "${modpack}/config";
          # Add more if the pack provides them (kubejs, defaultconfigs, etc.)
        };

      serverProperties = {
        motd = "Shared Survival (NixOS)";
        online-mode = true;
        "max-players" = 10;
      };

      jvmOpts = "-Xms6G -Xmx6G";  # adjust
      # opens port 25565 automatically with this module:
      openFirewall = true;
    };
  };
}