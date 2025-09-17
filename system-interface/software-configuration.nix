{ inputs, config, pkgs, lib, ... }:

{ 
  imports =
    [ # Include the results of the hardware scan + GLF modules
      ../system-hardware-shims/my-desktop/hardware-configuration.nix
      ../system-hardware-shims/my-desktop/firmware-configuration.nix
      # Include modular configuration components
      ./modules/mouse-pointer.nix
    ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    glf.environment.type = "gnome";
    glf.environment.edition = "studio";
    # GNOME Minimal + Forced Tiling Configuration
    environment.systemPackages = with pkgs; [
      gnomeExtensions.just-perfection      # Hide ALL UI elements permanently
      gnomeExtensions.tiling-shell        # Advanced tiling with Windows 11 Snap Assistant
      
      # Streaming layout script - Programmatic 1:4:1 layout generation
      (pkgs.writeShellScriptBin "streaming-layout" (builtins.readFile ./streaming-layout.sh))
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
      
      # Just Perfection - Clean desktop, top status panel shows only in omnibar overview (Super key)
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
      
      # Tiling Shell - MANDATORY TILING ENFORCEMENT
      "org/gnome/shell/extensions/tilingshell" = {
        # Core tiling settings - FORCE MANDATORY TILING
        "enable-tiling-system" = true;           # Enable tiling system
        "enable-autotiling" = true;              # Automatically tile new windows (MANDATORY)
        "enable-snap-assist" = true;             # Enable Windows 11-style snap assistant
        
        # Force all windows to be tiled - NO FLOATING ALLOWED
        "tiling-system-activation-key" = lib.gvariant.mkEmptyArray lib.gvariant.type.string;  # No key needed - always active
        "enable-span-multiple-tiles" = false;    # Disable spanning to prevent floating behavior
        
        # Additional enforcement settings - ENABLED for aggressive tiling
        "enable-tiling-system-windows-suggestions" = true;  # Force window suggestions for tiling
        "enable-snap-assistant-windows-suggestions" = true; # Force snap assistant suggestions
        
        # Gap settings - NO GAPS
        "inner-gaps" = lib.gvariant.mkUint32 0;  # No gaps between windows
        "outer-gaps" = lib.gvariant.mkUint32 0;  # No gaps at screen edges
        
        # Visual settings
        "enable-window-border" = false;          # No border around tiled windows
        "window-border-width" = lib.gvariant.mkUint32 0;  # No border width
        "window-border-color" = "#ffffff";       # White border (if enabled)
        
        # Tiling behavior - MANDATORY TILING
        "show-indicator" = false;                # Hide indicator on top panel
        "override-window-menu" = true;           # Add tiling buttons to window menu
        "restore-window-original-size" = false;  # NEVER restore to floating size
        "resize-complementing-windows" = true;   # Auto-resize other tiled windows
        "enable-wraparound-focus" = true;        # Wrap around when focusing windows
        
        # Disable untiling - FORCE MANDATORY TILING
        "untile-window" = lib.gvariant.mkEmptyArray lib.gvariant.type.string;  # NO keyboard shortcut to untile
        "tiling-system-deactivation-key" = lib.gvariant.mkEmptyArray lib.gvariant.type.string;  # NO key to deactivate tiling system
        
        # Window constraints - AGGRESSIVE TILING ENFORCEMENT
        "enable-screen-edges-windows-suggestions" = true;  # Force screen edge suggestions
        "quarter-tiling-threshold" = lib.gvariant.mkUint32 0;  # Immediate quarter tiling
        "snap-assistant-threshold" = lib.gvariant.mkInt32 0;   # Immediate snap assistant
        
        # Screen edge behavior
        "active-screen-edges" = true;            # Enable screen edge dragging
        "top-edge-maximize" = false;             # Don't maximize on top edge drag
        "enable-blur-snap-assistant" = false;    # No blur on snap assistant
        "enable-blur-selected-tilepreview" = false; # No blur on tile preview
        
        # Animation settings
        "snap-assistant-animation-time" = lib.gvariant.mkUint32 180; # Snap assistant animation
        "tile-preview-animation-time" = lib.gvariant.mkUint32 100;   # Tile animation
        
        # Keyboard shortcuts
        "enable-move-keybindings" = true;        # Enable keyboard shortcuts
        "move-window-left" = ["<Super>Left"];
        "move-window-right" = ["<Super>Right"];
        "move-window-up" = ["<Super>Up"];
        "move-window-down" = ["<Super>Down"];
      };
      
      
      # GNOME Shell - Battery info in overview mode
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;  # Enable battery percentage in top status panel (hidden by default)
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
    mkdir -p /home/${config._module.args.systemUsername}/.local/share/applications
    
    # Streaming Setup Launcher - Programmatic 1:4:1 layout
    cat > /home/${config._module.args.systemUsername}/.local/share/applications/streaming-setup.desktop << 'EOF'
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
    cat > /home/${config._module.args.systemUsername}/streaming-layout.sh << 'EOF'
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
    
    chmod +x /home/${config._module.args.systemUsername}/streaming-layout.sh
    chown ${config._module.args.systemUsername}:${config._module.args.systemUsername} /home/${config._module.args.systemUsername}/streaming-layout.sh
    
    chown -R ${config._module.args.systemUsername}:${config._module.args.systemUsername} /home/${config._module.args.systemUsername}/.local/share/applications
    chmod +x /home/${config._module.args.systemUsername}/.local/share/applications/*.desktop
  '';

  # TODO: remove armour-games, lutris, easy flatpakcba;d, bitwarden/ gnome keyring with automatic login after the MASTER login is done on a new machine - same for all other application login, they should automatically login like magic - if i want to stay in GNOME maybe migrate to keyring, otherwise I will probably be a WM only NIRI god and need to find other tools.
  # TODO: remove firefox for chromium or something that web-driver software plays well with.

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


    system.stateVersion = "25.05"; # DO NOT TOUCH 
  };
}
