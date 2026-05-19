{ inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    ./settings.nix
  ];
}