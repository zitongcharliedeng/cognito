{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";
  
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
    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system; # Now `system` is defined
        pkgs = pkgsStable; 
        modules = [
          ./system-interface 
          glf.nixosModules.default 
          maccel.nixosModules.default
        ];

        specialArgs = {
          pkgs-unstable = pkgsUnstable; 
        };
      };
    };
}
