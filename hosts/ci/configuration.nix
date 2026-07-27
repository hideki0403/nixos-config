{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/server
    ../../users/yukineko/account.nix
  ];

  networking.hostName = "ci";
  system.stateVersion = "25.11";

  home-manager.users.yukineko = import ../../users/yukineko/home/server;
}
