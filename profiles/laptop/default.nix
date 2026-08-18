{ privateModule, ... }:
{
  imports = [
    ../desktop
  ]
  ++ privateModule "profiles/laptop";
}
