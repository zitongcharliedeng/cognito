{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Discover all host configs programmatically inside ./system-hardware-shims/
      hosts = builtins.attrNames (builtins.readDir ./system-hardware-shims);

      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/default.nix
          ./system-hardware-shims/${name}/configuration.nix
          # Pass flake inputs down so any descendant modules can use them
          {
            _module.args.hyprland = hyprland;
            _module.args.xdph = xdph;

            # For faster downloads
            nix.settings = {
              substituters = [
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
            };
          }
        ];
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
