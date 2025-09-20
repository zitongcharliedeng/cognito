{ config, pkgs, lib, ... }:
# This still doesnt actually fix the 
{
  security.rtkit.enable = true;  # real-time scheduling for low-latency audio
  services.pulseaudio.enable = false;  # we want PipeWire’s PulseAudio, not legacy PA
  services.pipewire = {
    enable = true;
    alsa.enable = true;        # Let pipewire have API to emulate ALSA to apps like Resolve
    alsa.support32Bit = true;  # only if you run 32-bit apps (Wine/Steam plugins)
    pulse.enable = true;       # Let pipewire have API to emulate PulseAudio — helps with mic input in ALSA apps like Resolve.
    jack.enable = true;         # JACK compatibility (optional but harmless)
  };
  # Important: ensure ALSA → Pulse bridge is installed
  environment.systemPackages = with pkgs; [
    alsa-plugins   # provides libasound_module_pcm_pulse.so
    alsa-utils     # for aplay/arecord to test
    # The trick is that alsa-plugins ships little .so modules (like libasound_module_pcm_pulse.so) that ALSA can auto-load.
    # These plugins can intercept pcm.default and forward it somewhere else (PulseAudio, PipeWire, Jack…).
  ];
  environment.etc."alsa/conf.d".source =
  "${pkgs.alsa-lib}/share/alsa/alsa.conf.d";
}


