let
  userConfig = import ../../identity.nix;
in
{ ... }:
{
  programs.home-manager.enable = true;
  home.username = userConfig.username;
  home.homeDirectory = "/home/${userConfig.username}";
  home.stateVersion = "{{STATE_VERSION}}";
}
