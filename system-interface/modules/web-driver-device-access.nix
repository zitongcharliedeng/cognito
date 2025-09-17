{ config, pkgs, lib, ... }:

{
  # TODO: CONFIRM THESE UDEV RULES WORK FOR WEB SOFTWARE BROWSER DEVICE ACCESS. 
  # LAST BEHAVIOUR WAS mouse.wiki not working, wootility working but not able to update or access the restore device.
  # Enable official Wooting udev rules for browser access
  services.udev.packages = [ pkgs.wooting-udev-rules ];
  # Additional udev rules for other gaming devices
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
