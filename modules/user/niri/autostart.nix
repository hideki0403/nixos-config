{ ... }: {
  programs.niri.settings.spawn-at-startup = [
    # {
    #   command = [
    #     "systemctl"
    #     "--user"
    #     "start"
    #     "hyprpolkitagent"
    #   ];
    # }
    # { command = [ "xwayland-satellite" ]; }
    { command = [ "noctalia-shell" ]; }
  ];
}