{ config, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false; # TODO: Check
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}