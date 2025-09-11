{
  description = "Cognito OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland/master"; # pull directly from most upstream since unstable doesn't have layerrule rn
  };

  outputs = { self, nixpkgs, hyprland, ... }:
    let
      system = "x86_64-linux";

      # Discover all host configs programmatically inside ./system-hardware-shims/
      hosts = builtins.attrNames (builtins.readDir ./system-hardware-shims);

      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/default.nix
          ./system-hardware-shims/${name}/configuration.nix
          { _module.args.hyprland = hyprland; }
        ];
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
