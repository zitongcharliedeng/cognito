Per-user modules live here and are opt-in. These include both applications (windowed apps) and user-scoped services.

Structure:
- applications/: modules that install GUI apps and their launchers into the user's profile
- services/: modules that define per-user services (e.g., systemd user units)

Example usage in a user config (e.g., `users/zitchaden.nix`):

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ./modules/applications/enable_crossover_appimage.nix
    ./modules/services/enable_redlight.nix
  ];

  # Applications are enabled by import.
  # Services may still expose options:
  # redlight.enable = true;
}
```


