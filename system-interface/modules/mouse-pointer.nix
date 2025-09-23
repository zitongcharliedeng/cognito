{ config, pkgs, lib, ... }:

{
  # libinput configuration for mouse and touchpad
  services.libinput = {
    enable = true;
    # libinput is the default mouse-pointer input driver used by most
    # desktop environments and Wayland compositors. Enabling it is graceful and harmless.
    # So explictly removing any possibility of shitty default mouse accel is a win-win for me:
    mouse.accelProfile = "flat";
    touchpad.accelProfile = "flat";
  };

  # Maccel mouse acceleration configuration
  hardware.maccel = {
    enable = true;
    enableCli = true; # optional: lets you run `maccel tui` and `maccel set`
    parameters = {
      sensMultiplier = 0.2;
      inputDpi = 2000.0;
      yxRatio = 1.0;
      mode = "no_accel"; # No acceleration curve
      angleRotation = 9.0;
    };
  };
  # So you can run CLI/TUI without sudo
  users.groups.maccel.members = [ config._module.args.defaultUsername ];
}
