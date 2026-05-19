{ customConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "vm";
  system.stateVersion = "25.11";

  users.users.${customConfig.username}.extraGroups = [ "vboxsf" ];
}
