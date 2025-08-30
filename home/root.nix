{ pkgs, ... }:

{
  home.username = "root";
  home.homeDirectory = "/root";

  home.packages = with pkgs; [
    neofetch
    bat
    fd
  ];
}

