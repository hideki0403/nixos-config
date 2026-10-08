{ privateModule, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../profiles/server
    ../../modules/services/docker
    ../../modules/services/postgresql
    ../../modules/services/redis
    ../../users/yukineko/account.nix
  ]
  ++ privateModule "hosts/npg-ak1plus";

  # System
  networking.hostName = "npg-ak1plus";
  system.stateVersion = "26.05";

  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # User
  users.users.yukineko.extraGroups = [
    "docker"
    "networkmanager"
  ];
  home-manager.users.yukineko = import ../../users/yukineko/home/server;
}
