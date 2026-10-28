{ pkgs, pkgs-stable, inputs, ... }: {
  home.packages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    vesktop
    claude-code
    gimp

    # Software (stable)
    pkgs-stable.pgadmin4-desktopmode

    # Software (from flake)
    inputs.spotifast.packages."${pkgs.stdenv.hostPlatform.system}".default

    # Tools
    wakeonlan
    lazygit
  ];
}
