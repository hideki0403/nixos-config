{ mkSymlink, ... }:
{
  xdg.configFile."noctalia/config.toml" = {
    source = mkSymlink ./config.toml;
  };

  xdg.dataFile."nixos-config/noctalia-assets" = {
    source = mkSymlink ./assets;
  };
}
