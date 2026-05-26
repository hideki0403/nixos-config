{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system-optional/nvidia
    ../../modules/system-optional/secure-boot
  ];

  networking.hostName = "alienware-16-aurora";
  system.stateVersion = "25.11";
}
