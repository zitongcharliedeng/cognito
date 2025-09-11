{
  description = "Cognito OS";

  nixConfig = {
    # Pulling packages raw from i.e. github Hyperland will take a long time to pull dependencies,
    # so we use a cached version kindly made by cachix to speed up the process.
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+cdLXytWZyaUoVJgkPV+XYNXYK17xMLWfE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Track Hyprland master (I NEED THE LATEST FEATURES NOT ON NIXOS-UNSTABLE YET)
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # xdg-desktop-portal-hyprland (I NEED THE LATEST FEATURES NOT ON NIXOS-UNSTABLE YET)
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
          { _module.args.hyprland = hyprland; _module.args.xdph = xdph; }
        ];
      };
    in {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
