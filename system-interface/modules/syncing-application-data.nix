{ config, lib, pkgs, ... }:

{
  # service runs as your user (zitchaden), but is managed at the system level, so it keeps syncing even if you logged out but the system is on.
  services.syncthing = {
    enable = true;
    user = config._module.args.defaultUsername;   # your Linux username
    dataDir = "/home/${config._module.args.defaultUsername}"; # base dir for Syncthing config
    configDir = "/home/${config._module.args.defaultUsername}/.config/syncthing";
  };
}


