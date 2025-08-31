{ pkgs, ... }:

{ 
  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "23.11"; # Pick the same as system.stateVersion
  home.packages = with pkgs; [
    git
    neofetch
    bat
    fd
  ];
}

