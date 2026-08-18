{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.nh.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # Development
    nodejs-slim
    pnpm
    corepack
    deno
    python3

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
    sbctl
    fnm
    sops
    age
    ssh-to-age
    imagemagick
    ffmpeg
  ];
}
