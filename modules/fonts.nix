{ config, pkgs, ... }:

# Noto is the best popular font with broad symbol coverage ("no more tofu").
# Prefer Noto Sans Mono; Noto Mono is older and narrower in glyph coverage.
# Fallback will use non-mono Noto families when a glyph is missing.
let
  fontFamily = "Noto Sans Mono";
in
{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
    defaultFonts.monospace = [ fontFamily ];
    defaultFonts.emoji = [ "Noto Color Emoji" ];
  };

  environment.etc."xdg/waybar/style.css".text = ''
  * { font-family: "${fontFamily}", monospace; font-size: 12px; }
  #workspaces button.active { color: #ffffff; background: #3a3a3a; }
  '';

  environment.etc."xdg/kitty/kitty.conf".text = ''
  font_family ${fontFamily}
  bold_font ${fontFamily} Bold
  italic_font ${fontFamily} Italic
  bold_italic_font ${fontFamily} Bold Italic
  '';

  environment.etc."xdg/rofi/config.rasi".text = ''
  configuration { font: "${fontFamily} 12"; }
  '';
}


