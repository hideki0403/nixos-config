{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    vscode.fhs
    google-chrome
    microsoft-edge
    wezterm
    spotify
    seahorse

    # Development
    nodejs-slim
    pnpm
    corepack

    # CLI
    wget

    # Tools
    nixd
    nixfmt
    nixpkgs-fmt
    zip
    unzip
    _7zip-zstd
    nautilus
    keyd

    # IME
    fcitx5-mellow-themes
  ];
}
