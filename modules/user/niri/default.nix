{ inputs, ... }: {
  imports = [
    inputs.niri.homeModules.niri
    ./settings.nix
    ./unsupported-settings.nix
    ./keybinds.nix
    ./rules.nix
    ./autostart.nix
  ];
}
