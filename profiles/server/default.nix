{ privateModule, ... }:
{
  imports = [
    ../base
    ./packages.nix
    ./services.nix
  ]
  ++ privateModule "profiles/server";
}
