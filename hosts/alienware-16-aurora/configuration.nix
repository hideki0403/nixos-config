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

  hardware.nvidia = {
    powerManagement.finegrained = true;
    dynamicBoost.enable = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  users.users.yukineko.extraGroups = [ "networkmanager" ];
  home-manager.users.yukineko = import ../../users/yukineko/home/laptop;
}
