{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    vesktop
    spotify
    claude-code
    pgadmin4-desktopmode

    # Tools
    wakeonlan
    lazygit
  ];
}
