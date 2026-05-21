{ pkgs, ... }:
let
  genjyuu-gothic = pkgs.callPackage ../../../pkgs/genjyuu-gothic { };
in
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      terminus_font
      cantarell-fonts
      nerd-fonts.jetbrains-mono
      ibm-plex
      plemoljp-hs
      genjyuu-gothic
    ];

    fontDir.enable = true;
    fontconfig = {
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
    };
  };
}
