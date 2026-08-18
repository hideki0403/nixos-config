{ privateModule, ... }:
{
  imports = [
    ../base
    ./networking.nix
    ./packages.nix
    ./services.nix
    ./plymouth.nix
    ./fonts.nix
    ./xdg.nix
    ./keyboard-remap.nix
    ./ime.nix
  ]
  ++ privateModule "profiles/desktop";
}
