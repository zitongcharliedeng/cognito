{ inputs, config, pkgs, lib, ... }:

{ 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan + GLF modules
      ../hardware-configuration.nix
      ../customConfig
    ];
  
  glf.environment.type = "gnome";
  glf.environment.edition = "studio";

  # GNOME Minimal + Forced Tiling Configuration
  environment.systemPackages = with pkgs; [
    gnomeExtensions.just-perfection      # Hide ALL UI elements permanently
    gnomeExtensions.pop-shell           # Force tiling for ALL windows
  ];

  # Enable GNOME extensions management
  services.gnome.gnome-browser-connector.enable = true;

  # GNOME dconf settings - MINIMAL AND FORCED
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [{
    settings = {
      # Enable ONLY the essential extensions
      "org/gnome/shell" = {
        enabled-extensions = [
          "just-perfection-desktop@just-perfection"
          "pop-shell@system76.com"
        ];
        disable-user-extensions = false;
      };
      
      # Just Perfection - HIDE EVERYTHING PERMANENTLY
      "org/gnome/shell/extensions/just-perfection" = {
        # Core UI hiding
        dash = false;                    # No bottom dock/dash
        panel = false;                   # No top panel/status bar
        panel-in-overview = false;       # No panel in overview mode
        show-apps-button = true;         # Keep omnibar access (Super key)
        
        # Window behavior
        window-demands-attention-focus = true;  # Focus demanding windows automatically
        workspace-switcher-should-show = false; # Hide workspace switcher in overview
        
        # NO mouse reveal - everything stays hidden
        mouse-sensitive = false;         # No mouse hover reveal for dash or panel
        mouse-sensitive-fullscreen-window = false;  # No reveal for dash or panel even in fullscreen
      };
      
      # Pop Shell - FORCE TILING ON EVERYTHING
      "org/gnome/shell/extensions/pop-shell" = {
        tile-by-default = true;          # FORCE tiling for ALL windows
        active-hint = true;              # Show active window border
        smart-gaps = false;              # No automatic gap management
        gap-inner = lib.gvariant.mkUint32 0;  # No gaps between windows
        gap-outer = lib.gvariant.mkUint32 0;  # No gaps at screen edges
        show-title = false;              # No window title bars
        mouse-cursor-follows-active-window = true;  # Cursor follows focused window
        
        # Force tiling even for dialogs/popups (NOT notifications)
        tile-by-default-dialog = true;   # File dialogs, Steam launcher, etc.
        tile-by-default-popup = true;    # Application popups
        tile-by-default-utility = true;  # Utility windows
      };
      
      # GNOME Shell - Minimal interface
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;  # Battery in omnibar only
      };
      
      # Window manager - Focus behavior
      "org/gnome/desktop/wm/preferences" = {
        focus-mode = "sloppy";           # Focus follows mouse
        auto-raise = false;  #  Windows don't automatically come to front when focused, not that it matters on single layer tiling setups like mine.
        raise-on-click = true;  # Windows would only come to front when clicked
      };
      
      # Mutter - Workspace management
      "org/gnome/mutter" = {
        dynamic-workspaces = true;       # Dynamic workspaces
        workspaces-only-on-primary = true;  # Only show workspaces on primary display
        center-new-windows = false;      # Don't center - let tiling handle it
      };
    };
  }];
  
  # Enable extensions
  system.userActivationScripts.gnomeExtensions = ''
    if [ -x "$(command -v gnome-extensions)" ]; then
      gnome-extensions enable just-perfection-desktop@just-perfection
      gnome-extensions enable pop-shell@system76.com
    fi
  '';

  # Programmatic 1:4:1 layout launcher
  system.userActivationScripts.appLauncher = ''
    # Create .desktop file for streaming apps
    mkdir -p /home/zitchaden/.local/share/applications
    
    # Streaming Setup Launcher - Programmatic 1:4:1 layout
    cat > /home/zitchaden/.local/share/applications/streaming-setup.desktop << 'EOF'
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Streaming Setup
    Comment=Launch OBS + Steam + Discord in 1:4:1 layout
    Exec=sh -c 'cd ~ && ./streaming-layout.sh'
    Icon=obs
    Terminal=false
    Categories=AudioVideo;
    Keywords=streaming;obs;steam;discord;layout;
    EOF
    
    # Create the actual streaming layout script
    cat > /home/zitchaden/streaming-layout.sh << 'EOF'
    #!/bin/bash
    # Streaming Layout Script - Programmatic 1:4:1 arrangement
    
    # Launch applications
    obs &
    steam &
    discord &
    
    # Wait for applications to load
    sleep 5
    
    # Use Pop Shell's native tiling to create 1:4:1 layout
    # This works with the tiling window manager instead of against it
    
    # Create a custom layout using Pop Shell's JavaScript API
    gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "
      const windows = global.get_window_actors();
      const obs = windows.find(a => a.get_meta_window().get_wm_class() === 'obs');
      const steam = windows.find(a => a.get_meta_window().get_wm_class() === 'steam');
      const discord = windows.find(a => a.get_meta_window().get_wm_class() === 'discord');
      
      if (obs && steam && discord) {
        // Use Pop Shell's tiling system to create 1:4:1 ratio
        // This ensures perfect borders and no pixel overlap
        obs.get_meta_window().tile(0, 0, 1, 1/6);  // Top row
        steam.get_meta_window().tile(0, 1/6, 1, 4/6);  // Center row (4/6 height)
        discord.get_meta_window().tile(0, 5/6, 1, 1/6);  // Bottom row
      }
    "
    
    echo "Streaming layout applied: 1:4:1 (OBS:Steam:Discord)"
    EOF
    
    chmod +x /home/zitchaden/streaming-layout.sh
    chown zitchaden:zitchaden /home/zitchaden/streaming-layout.sh
    
    chown -R zitchaden:zitchaden /home/zitchaden/.local/share/applications
    chmod +x /home/zitchaden/.local/share/applications/*.desktop
  '';
  # TODO: move autogenerated shims by the great GLFOS installer into a separate folder, stuff like environment type is hardware agnostic respective to x86_64 machines (the only GLF prerequisite)
  glf.nvidia_config = {
    enable = true;
    laptop = false;
    # NVIDIA Corporation GA102 [GeForce RTX 3080] (rev a1)
    nvidiaBusId = "PCI:1:0:0";
  };

  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.
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
      sensMultiplier = 0.7;
      inputDpi = 2000.0;
      yxRatio = 1.0;
      mode = "no_accel"; # No acceleration curve
      angleRotation = 9.0;
    };
  };
  # So you can run CLI/TUI without sudo
  users.groups.maccel.members = [ "zitchaden" ];

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

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  networking.hostName = "cogNito"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zitchaden = {
    isNormalUser = true;
    description = "zitchaden";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "disk" "input" "render" "video" ];
  };

  system.stateVersion = "25.05"; # DO NOT TOUCH 
}
