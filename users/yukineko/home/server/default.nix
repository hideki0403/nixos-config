let
  userConfig = import ../../identity.nix;
in
{ privateModule, ... }:
{
  imports = [
    ../base
  ]
  ++ privateModule "users/${userConfig.username}/home/server";
}
