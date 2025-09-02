{ config, pkgs, ... }:
# TODO rename home/ folder to really be system or hardware agnostic or main
{
  # ============================================================================
  # CORE SYSTEM CONFIGURATION (Hardware Agnostic)
  # ============================================================================
  services.openssh.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.getty.extraArgs = [ "--autologin" "root" ];
  users.users.root = {
    isNormalUser = false;
    # Note: Password is the same as your NixOS installer sudo password
    # The initialPassword setting is would be ignored in this context after install.sh runs
  };
  
  # ============================================================================
  # DISPLAY MANAGER - XMonad on X11, with Rofi Omnibar for no-memorized shortcuts
  # ============================================================================
  
  # Graphical login screen
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  
  services.xserver.displayManager.defaultSession = "none+xmonad"; # tried i3 and awesome to no avail
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
          config = builtins.readFile ./scripts/xmonad.hs;
  };
  
  # Create configuration for xmobar, the status bar for XMonad
  systemd.tmpfiles.rules = [
    "d /root/.config/xmobar 0755 root root -"
  ];
  environment.etc."xmobar/xmobarrc".text = builtins.readFile ./scripts/xmobarrc;
  
  # Gaming:
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;


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
    chromium   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    rofi      # application launcher for omnibar
    xdotool   # X11 automation tool for omnibar commands
    xsel      # clipboard utility for XMonad commands
    xmobar    # status bar for XMonad
    wmctrl    # for window management and workspace info

    # XMonad command helper script TODO make shortcuts here and the omnibar sot actions link to be consistent
    (pkgs.writeScriptBin "xmonad-cmd" (builtins.readFile ./scripts/xmonad-cmd.sh))
    
    # Workspace preview script for xmobar (real app icons)
    (pkgs.writeScriptBin "workspace-preview" (builtins.readFile ./scripts/workspace-preview.sh))
    
    # Custom omnibar script with explicit bash dependency
    (pkgs.writeScriptBin "cognito-omnibar" (builtins.readFile ./scripts/cognito-omnibar.sh))
  ];


}
