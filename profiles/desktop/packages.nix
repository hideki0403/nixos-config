{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    ghostty
    seahorse
    nautilus
    keyd
    tail-tray
    xwayland-satellite

    # IME
    fcitx5-mellow-themes

    # Tools
    yt-dlp
  ];
}
