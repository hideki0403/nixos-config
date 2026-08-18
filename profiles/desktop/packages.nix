{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    ghostty
    spotify
    seahorse
    vesktop
    nautilus
    keyd
    tail-tray
    claude-code

    # IME
    fcitx5-mellow-themes

    # Tools
    yt-dlp
  ];
}
