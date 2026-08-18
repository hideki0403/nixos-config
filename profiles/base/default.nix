{ privateModule, ... }:
{
  imports = [
    ./accounts.nix
    ./boot.nix
    ./locale.nix
    ./openssh.nix
    ./rescue.nix
    ./shell-aliases.nix
    ./symlink.nix
    ./system.nix
    ./packages.nix
    ./tailscale.nix
  ]
  ++ privateModule "profiles/base";
}
