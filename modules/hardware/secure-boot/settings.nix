{ lib, ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.enable = lib.mkForce false;
    systemd-boot.enable = lib.mkForce false;
    timeout = 2;
  };

  # Enable lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
