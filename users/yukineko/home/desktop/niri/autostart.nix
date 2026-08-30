{ ... }: {
  programs.niri.settings.spawn-at-startup = [
    { command = [ "xwayland-satellite" ]; }
  ];
}
