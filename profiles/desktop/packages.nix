{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.firefox.enable = true;

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
