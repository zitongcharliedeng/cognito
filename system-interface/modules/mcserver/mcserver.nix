{ config, pkgs, lib, ... }:

{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/mc-sharedsurvival";

    servers.sharedsurvival = {
      enable = true;

      # Pick the loader/version that matches your pack.toml (Fabric vs NeoForge)
      package = pkgs.fabricServers.fabric-1_21_1;
      # If your pack is NeoForge, use:
      # package = pkgs.neoforgeServers.neoforge-1_21_1;

      symlinks =
        let
          modpack = pkgs.fetchPackwizModpack {
            # ✅ path INSIDE the repo (Nix will copy it into the store)
            url = "file://${./packs/shared-survival/pack.toml}";
            # placeholder; replace with the real hash after the first build
            packHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        in {
          "mods"   = "${modpack}/mods";
          "config" = "${modpack}/config";
        };

      serverProperties = {
        motd = "Shared Survival (NixOS)";
        online-mode = true;
        "max-players" = 10;
      };

      jvmOpts = "-Xms6G -Xmx6G";
      openFirewall = true;
    };
  };
}
