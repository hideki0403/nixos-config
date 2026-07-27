{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nginx
  ];
}
