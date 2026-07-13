{ customConfig, ... }:
{
  imports = [
    ../../modules/user
    ../../modules/user-optional/additional-packages
  ];

  home.username = customConfig.username;
  home.homeDirectory = "/home/${customConfig.username}";
  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
