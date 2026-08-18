{ mkSymlink, ... }:
{
  xdg.configFile."wezterm/wezterm.lua" = {
    source = mkSymlink ./wezterm.lua;
  };
}
