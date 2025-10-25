{ lib, ... }:

let
  nixConfigPerUser_Folder = ./users;

  getRootNixFileNames = folder:
    let
      rootEntries = builtins.readDir folder;
      rootEntryNames = builtins.attrNames rootEntries;
    in lib.filter (entryName:
      lib.hasSuffix ".nix" entryName &&
      rootEntries.${entryName} != "directory" &&
      rootEntries.${entryName} != "unknown"
    ) rootEntryNames;

  homeManagerUserConfigsPerUsername = builtins.listToAttrs (map (entryName: {
    name = lib.removeSuffix ".nix" entryName;
    value = {
      programs.home-manager.enable = true;
      systemd.user.startServices = "sd-switch";
      imports = [ (builtins.toPath "${nixConfigPerUser_Folder}/${entryName}") ];
    };
  }) (getRootNixFileNames nixConfigPerUser_Folder));
in
{
  config.home-manager.users = homeManagerUserConfigsPerUsername;
}


