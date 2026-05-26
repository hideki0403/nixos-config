{ customConfig, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "vm";
  system.stateVersion = "25.11";
  boot.loader.grub.device = lib.mkForce "/dev/sda";

  users.users.${customConfig.username}.extraGroups = [ "vboxsf" ];
}
