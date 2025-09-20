{ config, pkgs, lib, ... }:

{
  # Real-time scheduling for low-latency audio threads
  security.rtkit.enable = true;

  # ✅ Switch to native PulseAudio
  services.pulseaudio = {
    enable = true;     # Start PulseAudio daemon
    package = pkgs.pulseaudioFull; # Includes extra modules (Bluetooth, etc.)
    support32Bit = true; # 32-bit app compatibility (Wine/legacy plugins)
  };
  
  # ❌ Disable PipeWire completely
  services.pipewire.enable = lib.mkForce false;

  # Add user to audio group if not already
  users.users.${config._module.args.defaultUsername}.extraGroups = [ "audio" ];

  # Provide ALSA → Pulse bridge modules and tools
  environment.systemPackages = with pkgs; [
    alsa-plugins   # ships libasound_module_pcm_pulse.so for ALSA→Pulse
    alsa-utils     # gives you arecord/aplay to test
    pavucontrol    # optional but handy: GUI control for routing, verifying mic
  ];

  environment.etc."alsa/conf.d/99-pulse.conf".source =
  "${pkgs.alsa-plugins}/lib/alsa-lib/conf.pulse";

  # Rationale:
  # - DaVinci Resolve only supports ALSA. It will pick up “ALSA 1–8” devices.
  # - With PulseAudio running natively, ALSA apps use the alsa-plugins bridge
  #   (pcm.pulse + ctl.pulse) to forward audio/mic into PulseAudio.
  # - This setup is older and more widely tested than PipeWire’s emulation layer,
  #   so Resolve should finally see mic input working.
}
