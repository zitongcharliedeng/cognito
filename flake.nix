{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mynixui = {
      url = "git+file:./mynixui";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, mynixui, ... }:
    let
      system = "x86_64-linux";

      # Discover all host configs programmatically inside ./system-hardware-shims/
      hosts = builtins.attrNames (builtins.readDir ./system-hardware-shims);

      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/default.nix
          ./system-hardware-shims/${name}/configuration.nix
        ];
        specialArgs = { inherit mynixui; };
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
