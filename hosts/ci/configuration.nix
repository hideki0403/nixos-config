{ ... }:
{
  imports = [
    ../../modules/system
  ];

  networking.hostName = "ci";
  system.stateVersion = "25.11";

  # for CI testing
  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
}
