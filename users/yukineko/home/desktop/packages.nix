{ pkgs, pkgs-stable, ... }: {
  home.packages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    vesktop
    spotifast
    claude-code
    gimp
    pkgs-stable.pgadmin4-desktopmode

    # Tools
    wakeonlan
    lazygit
  ];
}
