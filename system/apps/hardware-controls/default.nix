{ config, pkgs, ... }:

# For managing hardware knobs and sliders (i.e. audio, brightness, display).
# Less about themes/software config, more about the machine itself.

{
  config = {
    environment.systemPackages = with pkgs; [
      # 🖥️ XFCE Settings Manager
      xfce4-settings
      # → General "control center" (keyboard, mouse, themes, power, accessibility).
      # → Works fine under Wayland EXCEPT the Display panel (because it uses XRandR).

      # 🎤 Pavucontrol
      pavucontrol
      # → Full GUI for audio & microphone device selection and volume.
      # → XFCE settings only has very basic sound config, so this is essential.

      # 🌞 Brightness control
      brightnessctl
      # → Command-line brightness tool (can be hooked into AGS later).
      # → XFCE panel brightness slider won't integrate with Niri.

      # 🖼️ Wayland-native display manager
      wlr-randr
      # → Like xrandr, but for wlroots compositors (Niri, Sway, Hyprland).
      # → Lets you set monitor resolution, refresh rate, position, etc.

      # 🔄 Kanshi
      kanshi
      # → Auto profile manager for Wayland displays.
      # → Example: when you plug in your HDMI monitor, it auto-applies a layout;
      #    when you unplug it, it reverts to laptop-only mode.
      # → This replaces the missing "Display" panel from XFCE with auto-logic.
    ];
  };
}
