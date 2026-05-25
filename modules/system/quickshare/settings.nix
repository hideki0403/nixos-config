{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rquickshare
  ];

  # mDNS/DNS-SD
  networking.firewall.allowedTCPPorts = [ 44555 ];
  networking.firewall.allowedUDPPorts = [ 44555 ];
}
