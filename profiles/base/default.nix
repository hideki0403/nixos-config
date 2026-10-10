{ privateModule, ... }:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./services.nix
    ./rescue.nix
    ./shell-aliases.nix
    ./system.nix
    ./packages.nix
    ./tailscale.nix
  ]
  ++ privateModule "profiles/base";
}
