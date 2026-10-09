{ lib, ... }:
{
  home-manager.users.yukineko.programs.niri.settings.outputs = {
    "eDP-1" = {
      scale = 1.25;
      variable-refresh-rate = true;
      position = {
        x = 0;
        y = 1080;
      };
    };
  }
  // lib.genAttrs [ "HDMI-A-1" "DP-1" "DP-2" "DP-3" "DP-4" ] (_: {
    position = {
      x = 64;
      y = 0;
    };
  });
}
