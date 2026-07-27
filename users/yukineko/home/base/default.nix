{ lib, flakeRoot, hasPrivateConfig, ... }:
{
  imports = [
    ./home.nix
    ./shell
    ./git
    ./neovim
  ] ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/users/yukineko");
}
