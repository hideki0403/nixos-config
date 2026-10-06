{ pkgs, pkgs-stable, ... }: {
  home.packages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    vesktop
    spotify
    claude-code
    gimp
    pkgs-stable.pgadmin4-desktopmode

    # Tools
    wakeonlan
    lazygit
  ];
}
