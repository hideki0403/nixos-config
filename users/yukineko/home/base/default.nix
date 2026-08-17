{
  lib,
  flakeRoot,
  hasPrivateConfig,
  ...
}:
{
  imports = [
    ./home.nix
    ./packages.nix
    ./shell
    ./git
    ./neovim
    ./ssh
  ]
  ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/users/yukineko");
}
