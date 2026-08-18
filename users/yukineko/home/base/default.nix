let
  userConfig = import ../../identity.nix;
in
{ privateModule, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
    ./shell
    ./git
    ./neovim
    ./ssh
  ]
  ++ privateModule "users/${userConfig.username}/home/base";
}
