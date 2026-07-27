{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop
    ../../users/yukineko/account.nix
  ];

  networking.hostName = "vm";
  system.stateVersion = "25.11";
  boot.loader.grub.device = lib.mkForce "/dev/sda";

  users.users.yukineko.extraGroups = [
    "networkmanager"
    "vboxsf"
  ];
  home-manager.users.yukineko = import ../../users/yukineko/home/desktop;
}
