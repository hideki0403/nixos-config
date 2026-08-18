{ privateModule, ... }:
{
  imports = [
    ../base
    ./packages.nix
  ]
  ++ privateModule "profiles/server";
}
