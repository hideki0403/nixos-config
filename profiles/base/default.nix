{
  lib,
  flakeRoot,
  hasPrivateConfig,
  ...
}:
{
  imports = [
    ./accounts.nix
    ./boot.nix
    ./locale.nix
    ./openssh.nix
    ./shell-aliases.nix
    ./system.nix
    ./packages.nix
    ./tailscale.nix
  ]
  ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/base");
}
