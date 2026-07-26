{ lib, flakeRoot, hasPrivateConfig, ... }:
{
  imports = [
    ./settings.nix
    ./niri
    ./noctalia
    # ./dank-material-shell
    ./wezterm
    ./shell
    ./git
    ./gnome-keyrings
    ./neovim
  ] ++ lib.optional hasPrivateConfig (flakeRoot + "/private/nix/modules/user");
}
