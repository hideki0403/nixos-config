{ config, ... }:
let
  pwd = "${config.home.homeDirectory}/nixos-config/modules/user/neovim";
in
{
  xdg.configFile."nvim/lua/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lua/config";
  };

  xdg.configFile."nvim/lua/plugins" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lua/plugins";
  };
}
