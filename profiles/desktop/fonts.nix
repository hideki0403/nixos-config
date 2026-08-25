{ pkgs, ... }:
let
  noto-jp = pkgs.callPackage ../../pkgs/noto-jp { };
  genjyuu-gothic = pkgs.callPackage ../../pkgs/genjyuu-gothic { };
in
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-jp
      terminus_font
      cantarell-fonts
      nerd-fonts.jetbrains-mono
      ibm-plex
      plemoljp-hs
      genjyuu-gothic
    ];

    fontDir.enable = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Gen Jyuu GothicL"
          "Noto Sans CJK JP"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="pattern">
            <edit name="family" mode="append" binding="strong">
              <string>Noto Sans CJK JP</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };
}
