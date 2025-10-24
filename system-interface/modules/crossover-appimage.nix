{ config, pkgs, lib, ... }:

let
  # Upstream release details
  version = "3.3.4";
  url = "https://github.com/lacymorrow/crossover/releases/download/v${version}/CrossOver-${version}-x86_64.AppImage";
  sha256 = "0hczjy1aci635a24imgs7ckbdqsvfpbmgi1nhlh0pb0y8ryjkm5b";

  app = pkgs.appimageTools.wrapType2 {
    inherit version;
    pname = "crossover";
    src = pkgs.fetchurl { url = url; sha256 = sha256; }; 
    extraPkgs = pkgs: [ ];
  };
in
{
  options.crossover = {
    enable = lib.mkEnableOption "Enable CrossOver AppImage";
  };

  config = lib.mkIf config.crossover.enable {
    environment.systemPackages = [ app ];
  };
}


