App modules in this directory are optional applications. The word "modules" here implies they are opt-in per-user.

Example import and usage:

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ./users/app-modules/crossover-appimage.nix
  ];

  config = {
    crossover.enable = true; # per-user choice via module option
  };
}
```


