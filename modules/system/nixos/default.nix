{ ... }:
{
  imports = [
    ./system.nix
    ./boot.nix
    ./ssh.nix
    ./locale.nix
    ./packages.nix
    ./services.nix
    ./fonts.nix
    ./xdg.nix
    ./keyboard-remap.nix
    ./ime.nix
    ./shell-aliases.nix
  ];
}
