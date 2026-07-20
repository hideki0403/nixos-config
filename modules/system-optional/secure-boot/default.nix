{ inputs, ... }: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    ./settings.nix
  ];
}
