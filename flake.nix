{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Packages I want latest versions of (not yet in nixos-unstable pkgs):
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    xdph.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    xdph.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, hyprland, xdph, ... }:
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
                "https://hyprland.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "hyprland.cachix.org-1:a7pgxzkh7+cdlXytW2JqwT/2WyiZ/3U4q8D8y1V9x6o="
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
