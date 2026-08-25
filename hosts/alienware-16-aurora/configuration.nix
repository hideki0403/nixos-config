{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./bootloader.nix
    ../../profiles/laptop
    ../../modules/services/docker
    ../../modules/hardware/nvidia
    ../../modules/hardware/secure-boot
    ../../users/yukineko/account.nix
  ];

  # System
  networking.hostName = "alienware-16-aurora";
  system.stateVersion = "25.11";
  hardware.enableAllFirmware = true;

  # GPU
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

  # User
  users.users.yukineko.extraGroups = [ "networkmanager" ];
  home-manager.users.yukineko = import ../../users/yukineko/home/laptop;
}
