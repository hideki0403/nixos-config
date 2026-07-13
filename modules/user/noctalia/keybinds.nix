{ pkgs, ... }:
let
  noctalia =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.niri.settings.binds = {
    # Volume
    "XF86AudioRaiseVolume".action.spawn = noctalia "volume-up"; # output increase
    "XF86AudioLowerVolume".action.spawn = noctalia "volume-down"; # output decrease
    "XF86AudioMute".action.spawn = noctalia "volume-mute"; # output mute
    "shift+XF86AudioRaiseVolume".action.spawn = noctalia "mic-volume-up"; # input increase
    "shift+XF86AudioLowerVolume".action.spawn = noctalia "mic-volume-down"; # input decrease
    "shift+XF86AudioMute".action.spawn = noctalia "mic-mute"; # input mute
    "control+XF86AudioMute".action.spawn = noctalia "panel-toggle control-center audio"; # open volume panel

    # Media
    "XF86AudioPlay".action.spawn = noctalia "media toggle";
    "XF86AudioNext".action.spawn = noctalia "media next";
    "XF86AudioPrev".action.spawn = noctalia "media previous";

    # Brightness
    "XF86MonBrightnessUp".action.spawn = noctalia "brightness-up";
    "XF86MonBrightnessDown".action.spawn = noctalia "brightness-down";

    # System
    "super+Space".action.spawn = noctalia "panel-toggle launcher";
    "super+Grave".action.spawn = noctalia "panel-toggle control-center";
    "super+V".action.spawn = noctalia "panel-toggle clipboard";
    "super+Escape".action.spawn = noctalia "panel-toggle session";
    "super+Comma".action.spawn = noctalia "settings-toggle";
    "super+L".action.spawn = noctalia "session lock";
    "super+Shift+S".action.spawn = noctalia "screenshot-region";
  };
}
