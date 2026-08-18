let
  userConfig = import ../../identity.nix;
in
{ privateModule, ... }:
{
  imports = [
    ../desktop
    ./packages.nix
  ]
  ++ privateModule "users/${userConfig.username}/home/laptop";
}
