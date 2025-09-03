{ config, pkgs, ... }:
# TODO rename home/ folder to really be system or hardware agnostic or main
{
  # ============================================================================
  # CORE SYSTEM CONFIGURATION (Hardware Agnostic)
  # ============================================================================
  services.openssh.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.getty.extraArgs = [ "--autologin" "ulysses" ];
  
  # Root user (for system administration)
  users.users.root = {
    isNormalUser = false;
    # Note: Password is the same as your NixOS installer sudo password
  };
  
  # Regular user for daily use and running things like steam without root implicitly for safety
  users.users.ulysses = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    initialPassword = "ulysses";
  };
  
  # Enable sudo for wheel group (ulysses user)
  security.sudo.enable = true;
  
  # ============================================================================
  # DISPLAY MANAGER - XMonad on X11, with Rofi Omnibar for no-memorized shortcuts
  # ============================================================================
  
  # Graphical login screen
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  # TODO make a new lightdm config for the new greeter with a default user, maybe switch to a different greeter
  services.xserver.displayManager.defaultSession = "none+xmonad"; # tried i3 and awesome to no avail
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = builtins.readFile ./scripts/xmonad.hs;
  };
  
  # Xmobar configuration will be created automatically by the user
  environment.etc."xmobar/xmobarrc".text = builtins.readFile ./scripts/xmobarrc;
  
  # Gaming:
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;
  # programs.steam.gamescopeSession.enable = true;
  # programs.gamemode.enable = true;
  # # Allow unfree packages (needed for Steam, etc.)
  # nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # SYSTEM PACKAGES (all hardware agnostic)
  # ============================================================================
  environment.systemPackages = with pkgs; [
    protonup
    mangohud
    git
    vim
    htop
    tmux
    kitty     # hardware-agnostic terminal
    scrot     # screenshot tool
    xclip     # clipboard utility
    xfce.thunar  # file manager and explorer
    firefox   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    rofi      # application launcher for omnibar
    xdotool   # X11 automation tool for omnibar commands
    xsel      # clipboard utility for XMonad commands
    xmobar    # status bar for XMonad
    wmctrl    # for window management and workspace info
    papirus-icon-theme  # Single icon theme for applications

    # XMonad command helper script TODO make shortcuts here and the omnibar sot actions link to be consistent
    (pkgs.writeScriptBin "xmonad-cmd" (builtins.readFile ./scripts/xmonad-cmd.sh))
    
    # Workspace preview script for xmobar (real app icons)
    (pkgs.writeScriptBin "workspace-preview" (builtins.readFile ./scripts/workspace-preview.sh))
    
    # Custom omnibar script with explicit bash dependency
    (pkgs.writeScriptBin "cognito-omnibar" (builtins.readFile ./scripts/cognito-omnibar.sh))
    
    # Custom rofi mode script
    (pkgs.writeScriptBin "custom-actions-mode" (builtins.readFile ./scripts/custom-actions-mode.sh))
  ];


}
