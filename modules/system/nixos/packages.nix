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
    ghostty
    spotify
    seahorse

    # Development
    nodejs-slim
    pnpm
    corepack

    # CLI
    neovim
    bind
    wget
    fastfetch
    jq

    # Tools
    nixd
    nixfmt
    nixpkgs-fmt
    zip
    unzip
    _7zip-zstd
    nautilus
    keyd
    sbctl
    fnm

    # IME
    fcitx5-mellow-themes
  ];
}
