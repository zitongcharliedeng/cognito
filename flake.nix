{
  description = "Cognito OS - Flake config (minimal test)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.cognito-dev = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/cognito-dev/configuration.nix
      ];
    };
  };
}

