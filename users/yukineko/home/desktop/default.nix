let
  userConfig = import ../../identity.nix;
in
{ privateModule, ... }:
{
  imports = [
    ../base
    ./packages.nix
    ./mime-apps.nix
    ./niri
    ./noctalia
    # ./dank-material-shell
    ./gtk
    ./ghostty
    ./wezterm
    ./thunderbird
    ./gnome-keyrings
  ]
  ++ privateModule "users/${userConfig.username}/home/desktop";
}
