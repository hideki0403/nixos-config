{ pkgs, pkgs-stable, inputs, ... }: {
  home.packages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    vesktop
    claude-code
    gimp
    # pgadmin4-desktopmode

    # Software (stable)
    # pkgs-stable.example

    # Software (from flake)
    inputs.spotifast.packages."${pkgs.stdenv.hostPlatform.system}".default

    # Tools
    wakeonlan
    lazygit
  ];
}
