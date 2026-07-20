{ inputs, ... }: {
  imports = [
    inputs.dms.nixosModules.greeter
    ./settings.nix
  ];
}
