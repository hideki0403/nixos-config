{ privateModule, ... }:
{
  imports = [
    ./settings.nix
  ]
  ++ privateModule "modules/networking/wired-8021x-univ";
}
