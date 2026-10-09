{ ... }:
{
  networking.networkmanager = {
    enable = true;
    settings."connection-ethernet" = {
      match-device = "type:ethernet";
      "ipv4.route-metric" = 50;
      "ipv6.route-metric" = 50;
    };
  };

  hardware.bluetooth.enable = true;
}
