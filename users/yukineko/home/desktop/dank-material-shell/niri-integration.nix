{ ... }: {
  programs.niri.settings.spawn-at-startup = [
    {
      command = [
        "dms"
        "run"
      ];
    }
  ];
}
