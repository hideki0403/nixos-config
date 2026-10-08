{ privateModule, ... }:
{
  imports = [
    ./settings.nix
  ]
  ++ privateModule "modules/services/postgresql";
}
