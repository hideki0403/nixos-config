{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/laptop
    ../../modules/services/docker
    ../../modules/hardware/nvidia
    ../../modules/hardware/secure-boot
    ../../users/yukineko/account.nix
  ];

  networking.hostName = "alienware-16-aurora";
  system.stateVersion = "25.11";
  hardware.enableAllFirmware = true;

  users.users.yukineko.extraGroups = [ "networkmanager" ];
  home-manager.users.yukineko = import ../../users/yukineko/home/laptop;
}
