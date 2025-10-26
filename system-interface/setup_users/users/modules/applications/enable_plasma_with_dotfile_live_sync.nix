{ self, config, pkgs, lib, plasmaManagerRc2nix, plasmaManagerHomeModule, ... }:

let
  MyLocalPlasmaConfigLCAFolder = "${config.home.homeDirectory}/.config";
  MyNixOSPlasmaConfigFolder = "${config.home.homeDirectory}/cognito/.config/plasma";
in
{
  systemd.user.services."export-plasma-dotfiles-to-nixconfig" = {
    Unit.Description = "Export Plasma config to monorepo as a Nix module using plasma-manager";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -lc ${lib.escapeShellArg "${plasmaManagerRc2nix} > ${MyNixOSPlasmaConfigFolder}/plasma.nix"}";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.paths."watch-plasma-dotfiles-containing-folder-for-changes" = {
    Unit.Description = "Watch KDE Plasma config (LCA) for changes, tell the export service to run each change detected.";
    Path = {
      Unit = "export-plasma-dotfiles-to-nixconfig.service";
      PathChanged = [ MyLocalPlasmaConfigLCAFolder ];
      PathModified = [ MyLocalPlasmaConfigLCAFolder ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  imports = [ plasmaManagerHomeModule (import "${MyNixOSPlasmaConfigFolder}/plasma.nix") ];
}


