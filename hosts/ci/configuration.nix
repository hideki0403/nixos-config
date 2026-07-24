{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "ci";
  system.stateVersion = "25.11";
}
