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
    gnomeExtensions.tiling-shell        # Advanced tiling with Windows 11 Snap Assistant
  ];

  # Enable GNOME extensions management
  services.gnome.gnome-browser-connector.enable = true;

  # GNOME dconf settings - MINIMAL AND FORCED
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [{
    settings = {
      # Enable extensions for minimal UI + tiling
      "org/gnome/shell" = {
        enabled-extensions = [
          "just-perfection-desktop@just-perfection"
          "tilingshell@ferrarodomenico.com"
        ];
        disable-user-extensions = false;
      };
      
      # Just Perfection - Clean desktop, tp status panel only in overview
      "org/gnome/shell/extensions/just-perfection" = {
        # Core UI hiding
        dash = false;                    # No bottom dock/dash
        panel = false;                   # No top panel on desktop
        panel-in-overview = true;        # Show panel ONLY in overview mode (Super key)
        show-apps-button = true;         # Keep omnibar access (Super key)
        
        # Window behavior
        window-demands-attention-focus = true;  # Focus demanding windows automatically
        workspace-switcher-should-show = false; # Hide workspace switcher in overview
        
        # NO mouse reveal - everything stays hidden
        mouse-sensitive = false;         # No mouse hover reveal for dash or panel
        mouse-sensitive-fullscreen-window = false;  # No reveal for dash or panel even in fullscreen
      };
      
      # Tiling Shell - Advanced tiling with Window Snap Assistant
      "org/gnome/shell/extensions/tilingshell" = {
        auto-tile = true;                # Automatically tile new windows
        auto-tile-dialogs = false;        # Tile dialogs and popups
        auto-tile-utilities = false;      # Tile utility windows
        
        # Tiling behavior
        show-tiling-buttons = true;      # Show tiling buttons in context menu
        show-snap-assistant = true;      # Enable Windows 11-style snap assistant
        show-tiling-hint = true;         # Show tiling hints when dragging
        
        # Layout settings
        default-layout = "columns";      # Default to column layout
        per-workspace-layout = true;     # Different layouts per workspace
        
        # Visual settings
        show-border = false;              # Show border around tiled windows
        border-radius = 0;               # No rounded corners for sharp edges
        border-width = 0;                # Thin border
        border-color = "#ffffff";        # White border
        
        # Gap settings
        inner-gap = 0;                   # No gaps between windows
        outer-gap = 0;                   # No gaps at screen edges
        
        # Keyboard shortcuts (can be customized)
        enable-keybindings = true;       # Enable keyboard shortcuts
        move-window-left = ["<Super>Left"];
        move-window-right = ["<Super>Right"];
        move-window-up = ["<Super>Up"];
        move-window-down = ["<Super>Down"];
      };
      
      
      # GNOME Shell - Battery info in overview mode
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;  # Battery percentage in top panel (visible in overview)
      };
      
      # Window manager - Focus behavior (still relevant with Tiling Shell)
      "org/gnome/desktop/wm/preferences" = {
        focus-mode = "sloppy";           # Focus follows mouse
        auto-raise = false;              # Don't auto-raise windows
        raise-on-click = true;           # Raise windows when clicked
      };
      
      # Mutter - Workspace management (still relevant with Tiling Shell)
      "org/gnome/mutter" = {
        dynamic-workspaces = true;       # Dynamic workspaces - automatically creates/destroys workspaces as needed, no fixed number
        workspaces-only-on-primary = true;  # Only show workspaces on primary display
        center-new-windows = false;      # Don't center - let Tiling Shell handle it
      };
    };
  }];
  
  # Enable extensions
  system.userActivationScripts.gnomeExtensions = ''
    if [ -x "$(command -v gnome-extensions)" ]; then
      gnome-extensions enable just-perfection-desktop@just-perfection
      gnome-extensions enable tilingshell@ferrarodomenico.com
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
    # Streaming Layout Script - Programmatic 1:4:1 arrangement using Tiling Shell
    
    # Launch applications
    obs &
    steam &
    discord &
    
    # Wait for applications to load
    sleep 5
    
    # Use Tiling Shell's API to create custom 1:4:1 layout
    # Tiling Shell supports custom layouts via JavaScript API
    
    # Create a custom 1:4:1 layout using Tiling Shell's API
    gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "
      // Get Tiling Shell extension
      const tilingShell = global.get_extension('tilingshell@ferrarodomenico.com');
      if (!tilingShell) {
        console.log('Tiling Shell extension not found');
        return;
      }
      
      const tilingManager = tilingShell.imports.manager;
      
      // Find windows by class name
      const windows = global.get_window_actors();
      const obs = windows.find(a => a.get_meta_window().get_wm_class() === 'obs');
      const steam = windows.find(a => a.get_meta_window().get_wm_class() === 'steam');
      const discord = windows.find(a => a.get_meta_window().get_wm_class() === 'discord');
      
      if (obs && steam && discord) {
        // Create custom 1:4:1 layout using Tiling Shell's layout system
        const layout = {
          name: 'Streaming Setup',
          columns: 1,
          rows: 3,
          tiles: [
            { x: 0, y: 0, width: 1, height: 1/6 },    // OBS - Top row
            { x: 0, y: 1/6, width: 1, height: 4/6 },  // Steam - Center row (4/6 height)
            { x: 0, y: 5/6, width: 1, height: 1/6 }   // Discord - Bottom row
          ]
        };
        
        // Apply the layout to the current workspace
        tilingManager.setLayout(layout);
        
        // Tile the windows to their respective positions
        obs.get_meta_window().tile(0, 0, 1, 1/6);
        steam.get_meta_window().tile(0, 1/6, 1, 4/6);
        discord.get_meta_window().tile(0, 5/6, 1, 1/6);
      }
    "
    
    echo "Streaming layout applied: 1:4:1 (OBS:Steam:Discord) using Tiling Shell"
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
