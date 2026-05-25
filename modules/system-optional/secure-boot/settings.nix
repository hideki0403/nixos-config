{ pkgs, lib, ... }: {
  # boot.loader.grub.enable = lib.mkForce false;
  boot.loader = {
    grub.enable = lib.mkForce false;
    systemd-boot.enable = lib.mkForce false;
    timeout = 0;
  };

  # Enable lanzaboote
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Install rEFInd
  environment.systemPackages = [
    pkgs.refind
  ];
}
