{ inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    ./settings.nix
    ./keybinds.nix
    ./niri-integration.nix
    ./symlink.nix
  ];
}
