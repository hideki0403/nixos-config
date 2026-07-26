{ lib, flakeRoot, hasPrivateConfig, ... }:
{
  imports = [
    ./nixos
    ./tailscale
    ./plymouth
    ./docker
    # ./dms-greeter
  ] ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/modules/system");
}
