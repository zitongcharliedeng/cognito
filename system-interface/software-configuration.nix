{ inputs, config, pkgs, lib, ... }:

{ 
  imports =
    [ # Include the results of the hardware scan + GLF modules
      ../system-hardware-shims/my-desktop/hardware-configuration.nix
      ../system-hardware-shims/my-desktop/firmware-configuration.nix
      ./modules/mouse-pointer.nix
      ./modules/web-driver-device-access.nix
    ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    glf.environment.type = "gnome";
    glf.environment.edition = "studio";
    
    environment.systemPackages = with pkgs; [
      # Application Launcher - Fuzzel (modern Wayland launcher)
      fuzzel
      
      # Screen lock
      swaylock
      
      # GNOME System Controls (preserved for hardware management)
      gnome-control-center
      gnome-settings-daemon
      gnome-system-monitor
      gnome-disk-utility
      gnome-terminal
      gnome-calculator
      gnome-screenshot
    ];

    # Enable Niri window manager
    programs.niri.enable = true;
    
    # Fuzzel configuration (minimal setup, will replace with AGS later)
    # Fuzzel will be available as fuzzel in system packages
    # Configuration will be handled via AGS in the future
    
    # Niri configuration with Fuzzel key bindings
    environment.etc."niri/config".text = ''
      # Niri configuration with Fuzzel launcher
      
      # Key bindings
      keybindings = [
        # Application launcher
        "Super+Space" = "spawn fuzzel";
       
        # Window management
        "Super+Q" = "close-window";
        "Super+F" = "toggle-fullscreen";
        "Super+M" = "toggle-maximize";
        
        # Lock screen
        "Super+Shift+L" = "spawn swaylock";
 
        # Screenshot
        "Print" = "spawn gnome-screenshot";
        "Super+Print" = "spawn gnome-screenshot -a";
      ];
      
      # Default layout
      layout = "tile";
      
      # Window rules
      window-rules = [
        # Floating windows
        { match = { app-id = "org.gnome.Calculator"; }; mode = "floating"; }
        { match = { app-id = "org.gnome.Nautilus"; }; mode = "floating"; }
      ];
    '';
    
    # Override GLF GNOME environment to disable GUI components
    # Keep only system controls, disable GNOME Shell and display manager
    services.gnome.gnome-settings-daemon.enable = true;
    services.gnome.gnome-keyring.enable = true;
    
    # Disable GNOME GUI components that conflict with Niri
    services.xserver.desktopManager.gnome.enable = false;
    services.xserver.displayManager.gdm.enable = false;
    services.gnome.core-shell.enable = false;
    services.gnome.core-apps.enable = false;
    
    # GNOME dconf - ESSENTIAL for system controls to work properly
    # dconf is GNOME's configuration database that stores settings for:
    # - GNOME Control Center (hardware settings, display, audio, input devices)
    # - GNOME Settings Daemon (system-wide preferences and hardware integration)
    # - GNOME Keyring (encrypted password storage)
    # - GNOME applications (terminal, screenshot, calculator preferences)
    # Without dconf, GNOME system controls cannot save or load settings
    programs.dconf.enable = true;
    
    # TODO: Future AGS integration for advanced status bar and launcher
    # TODO: Implement streaming layout script for Niri using:
    # - Niri's layout system for 1:4:1 arrangement
    # - Window positioning via Niri's API
    # - Application launching and workspace management
    # 
    # Original streaming layout logic (commented for future revival):
    # 1. Launch applications: obs, steam, discord
    # 2. Wait for applications to load
    # 3. Get screen dimensions using xrandr or Niri's display API
    # 4. Calculate 1:4:1 layout ratios (top: 1/6, center: 4/6, bottom: 1/6)
    # 5. Use Niri's layout system to arrange windows programmatically
    # 6. Apply tiling constraints to prevent floating behavior
    #
    # Key differences for Niri implementation:
    # - Use Niri's layout system instead of GNOME Shell JavaScript API
    # - Use Niri's window management commands instead of Meta.Window
    # - Use Niri's workspace management for application placement
    # - Leverage Niri's mandatory tiling (no floating windows possible)

  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
  };
}
