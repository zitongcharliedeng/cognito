{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  environment.systemPackages = [
  # Add your stable apps here (exemple: pkgs.btop)



  # Add your unstable apps here (exemple: pkgs-unstable.btop)


  ];


  # Add your custom configuration here ↓

  # Enable automatic system upgrades via NixOS's built-in service.
  # This uses a systemd timer to periodically rebuild against the latest
  # flake inputs (including GLF curated channels) and switch to that build.
  # We enable this to get the "GLF automatic updates" experience.
  system.autoUpgrade = {
    enable = true;
    # Build from this system flake. For a system copy under /etc/nixos,
    # using a path URL avoids needing network Git credentials:
    flake = "path:/etc/nixos";
    dates = "04:40";
    randomizedDelaySec = "1h";
    allowReboot = true;
  };
}
