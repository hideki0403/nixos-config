{ mkSymlink, ... }:
{
  xdg.configFile."nvim/lua/config" = {
    source = mkSymlink ./lua/config;
  };

  xdg.configFile."nvim/lua/plugins" = {
    source = mkSymlink ./lua/plugins;
  };
}
