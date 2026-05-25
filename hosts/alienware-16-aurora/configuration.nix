{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system-optional/nvidia
    ../../modules/system-optional/secure-boot
  ];

  networking.hostName = "laptop";
  system.stateVersion = "25.11";
}
