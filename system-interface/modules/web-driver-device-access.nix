{ config, pkgs, lib, ... }:

{
  # Mouse.wiki for mouse web software seems to work, not sure if these udev rules are needed, but if it ain't broke...
  services.udev.packages = [ pkgs.wooting-udev-rules ];
  services.udev.extraRules = ''
    # Universal HID raw device access for browser/WebHID
    SUBSYSTEM=="hidraw", TAG+="uaccess"
    
    # Universal input device access for browser/WebHID  
    SUBSYSTEM=="input", TAG+="uaccess"
    
    # Specific gaming device rules
    # Azeron devices (keypad)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="12f7", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="12f7", TAG+="uaccess"
    
    # G-Wolves HSK Pro mouse
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="33e4", ATTRS{idProduct}=="5803", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="33e4", ATTRS{idProduct}=="5803", TAG+="uaccess"
  '';
  # TODO: handle this programmatically for all devices if it works in the future.
}
