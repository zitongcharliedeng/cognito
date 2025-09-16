## GLF-OS based NixOS configuration

This repository is a flake-based NixOS configuration that uses GLF-OS as a base.

### Layout

```mermaid
flowchart TD
  A[/flake.nix/] -->|defines| B[nixosConfigurations."GLF-OS"]
  A -->|inputs| C[glf-channels]
  A -->|inputs| D[nixpkgs]
  A -->|inputs| E[nixpkgs-unstable]
  A -->|inputs| F[glf (GLF-OS root flake)]

  B -->|modules| G[configuration.nix]
  B -->|modules| H[glf.nixosModules.default]

  B -->|modules| I[system-interface/]
  I --> J[system-interface/default.nix]
  J --> K[hardware-configuration.nix]
  J --> L[customConfig/]
  L --> M[customConfig/default.nix]

  subgraph "Auto-updates"
    N[system.autoUpgrade] -->|timer| O[nixos-upgrade.timer]
    N -->|service| P[nixos-upgrade.service]
  end

  M -. enables .-> N
```

### Notes

- GLF curated channels are followed via `inputs.glf-channels` and `nixpkgs.follows` in `flake.nix`.
- Automatic updates use NixOS's built-in auto-upgrade service (a systemd timer) that periodically rebuilds from this flake and switches to it.
- Customizations should go in `customConfig/default.nix`. The GLF module is also included as a module in `flake.nix`.
- System configuration lives under `system-interface/` for clarity.


