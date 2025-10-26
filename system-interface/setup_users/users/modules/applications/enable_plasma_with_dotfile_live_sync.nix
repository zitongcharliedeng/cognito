{ self, config, pkgs, lib, plasmaManagerRc2nix, plasmaManagerHomeModule, ... }:

let
  # Lowest Common Ancestor for user Plasma KConfig (Plasmashell, KWin, etc.)
  MyLocalPlasmaConfigLCAFolder = "${config.home.homeDirectory}/.config";
  # Target location in your monorepo for Plasma manager export (top-level .config)
  MyNixOSPlasmaConfigFolder = "${config.home.homeDirectory}/cognito/.config/plasma";
in
{
  assertions = [
    {
      assertion = plasmaManagerRc2nix != null;
      message = "plasmaManagerRc2nix must be provided (rc2nix from plasma-manager); no fallback is supported.";
    }
  ];

  systemd.user.services."export-plasma-dotfiles-to-nixconfig" = {
    Unit.Description = "Export Plasma config to monorepo as a Nix module using plasma-manager";
    Service = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.bash}/bin/bash" "-c"
        ''
          "${plasmaManagerRc2nix}" > "${MyNixOSPlasmaConfigFolder}/plasma.nix"
        ''
      ];
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

  imports = [ plasmaManagerHomeModule (import "${self}/.config/plasma/plasma.nix") ];
}


