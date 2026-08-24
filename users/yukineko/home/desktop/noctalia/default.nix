{ ... }: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./niri-integration.nix
    ./symlink.nix
    ./packages.nix
  ];
}
