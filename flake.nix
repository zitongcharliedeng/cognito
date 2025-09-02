{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      # Discover all host configs programmatically inside ./hosts/
      hosts = builtins.attrNames (builtins.readDir ./hosts);

      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/system.nix
          ./hosts/${name}/configuration.nix
        ];
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
