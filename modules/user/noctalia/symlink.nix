{ config, ... }:
let
  pwd = "${config.home.homeDirectory}/nixos-config/modules/user/noctalia";
in
{
  xdg.configFile."noctalia/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.toml";
  };
}
