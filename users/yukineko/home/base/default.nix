{ lib, flakeRoot, hasPrivateConfig, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
    ./shell
    ./git
    ./neovim
  ] ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/users/yukineko");
}
