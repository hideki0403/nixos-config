{ config, ... }:
let
  pwd = "${config.home.homeDirectory}/nixos-config/users/yukineko/home/desktop/wezterm";
in
{
  xdg.configFile."wezterm/wezterm.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pwd}/wezterm.lua";
  };
}
