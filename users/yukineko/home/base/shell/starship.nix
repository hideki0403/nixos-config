{ lib, ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = lib.mkMerge [
      (fromTOML (builtins.readFile ./starship/preset-nf-symbols.toml))
      (fromTOML (builtins.readFile ./starship/config.toml))
    ];
  };
}
