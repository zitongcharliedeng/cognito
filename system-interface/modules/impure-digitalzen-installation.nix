{ config, lib, pkgs, ... }:

{
  # DigitalZen installer integration
  #
  # This runs the vendor's installation script *verbatim* at every
  # nixos-rebuild switch, just like doing:
  #
  #   curl -fsSL https://api.digitalzen.app/downloads/DigitalZen-setup.sh | bash
  #   from https://www.digitalzen.app/linux-installation-instructions as of 2025-09-19.
  #
  # Notes:
  # - This is fully *impure*: the script is always fetched live from upstream.
  # - There is NO rollback safety. GRUB rollbacks do not revert DigitalZen,
  #   because it is installed outside the Nix store (e.g. under /opt and ~/.config).
  # - The upside: it's the most 1:1 faithful reproduction of the vendor's
  #   install instructions, minimal code, no hashes to update and I am too lazy to make a bespoke flake for it.
  #
  system.activationScripts.digitalzen = {
    deps = [ "users" ];
    text = ''
      echo "Installing DigitalZen via impure fetch..."
      # Ensure required tools are available
      export PATH=${lib.makeBinPath [ pkgs.curl pkgs.procps pkgs.gnugrep pkgs.coreutils ]}:$PATH

      ${pkgs.curl}/bin/curl -fsSL https://api.digitalzen.app/downloads/DigitalZen-setup.sh | ${pkgs.bash}/bin/bash
    '';
  };
}
