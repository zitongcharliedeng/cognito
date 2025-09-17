{
  description = "Cognito OS - GLF-OS based NixOS configuration";
  
  inputs = {
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/glf-os-channels.git?ref=main"; # Repository responsible for switching from one GLF stable to another
    nixpkgs.follows = "glf-channels/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=main"; # References the GLF-OS root flake
    maccel.url = "github:Gnarus-G/maccel"; # Official maccel repo with NixOS support
  };

  # About updates:
  # - You follow GLF's curated channel via `glf-channels` and `nixpkgs.follows` above.
  # - "Automatic updates" are performed by NixOS's built-in auto-upgrade service (a systemd timer
  #   that periodically rebuilds from a flake source), not by a custom GLF binary.
  # - You would explicitly enable this auto-upgrade service in config using `system.autoUpgrade.enable = true;`
  #   and point `system.autoUpgrade.flake` at your system flake (e.g. "path:/etc/nixos").

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glf,
      maccel,
      self,
      ...
    }: 

    let
      system = "x86_64-linux"; 
      
      # Configuration for stable nixpkgs (will be the default `pkgs`)
      pkgsStable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Configuration for nixpkgs unstable (passed as a special argument)
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Discover all host configs programmatically inside ./system-hardware-shims/
      hosts = builtins.attrNames (builtins.readDir ./system-hardware-shims);
      # Function to create a host configuration
        mkHost = name: nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = pkgsStable;
          modules = [
            ./system-interface/software-configuration.nix
            ./system-hardware-shims/${name}/hardware-configuration.nix
            ./system-hardware-shims/${name}/firmware-configuration.nix
            glf.nixosModules.default 
            maccel.nixosModules.default
          ];

        specialArgs = {
          pkgs-unstable = pkgsUnstable;
          inputs = { inherit self; };
        };
      };
    in
    {
      nixosConfigurations =
        builtins.listToAttrs (map (name: { name = name; value = mkHost name; }) hosts);
    };
}
