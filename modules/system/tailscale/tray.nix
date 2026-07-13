{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tail-tray
  ];
}