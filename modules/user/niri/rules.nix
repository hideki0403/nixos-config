{ ... }:
{
  programs.niri.settings = {
    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 16.0;
          top-right = 16.0;
          bottom-left = 16.0;
          bottom-right = 16.0;
        };
        clip-to-geometry = true;
      }
    ];

    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-wallpaper*"; } ];
        place-within-backdrop = true;
      }
      {
        matches = [ { namespace = "^noctalia-overview*"; } ];
        place-within-backdrop = true;
      }
    ];
  };
}
