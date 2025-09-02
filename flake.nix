{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Discover all host configs programmatically inside ./hosts/
      hosts = builtins.attrNames (builtins.readDir ./hosts);

      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/system.nix
          ./hosts/${name}/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # ⚠️ For now, root is the only HM user
            home-manager.users.root = import ./home/root.nix;
          }
        ];
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
