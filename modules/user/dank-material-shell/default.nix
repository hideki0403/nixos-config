{ inputs, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./settings.nix
    ./niri-integration.nix
    ./keybinds.nix
  ];
}
