{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    vscode.fhs
    zed-editor-fhs
    google-chrome
    ghostty
    spotify
    seahorse
    vesktop

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
    btop

    # Tools
    nil
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
    sops
    age
    ssh-to-age

    # IME
    fcitx5-mellow-themes
  ];
}
