{ pkgs, ... }:
let
  dms =
    cmd:
    [
      "dms"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.niri.settings.binds = {
    # Volume
    "XF86AudioRaiseVolume".action.spawn = dms "audio increase";
    "XF86AudioLowerVolume".action.spawn = dms "audio decrease";
    "XF86AudioMute".action.spawn = dms "audio mute"; # output mute
    "shift+XF86AudioMute".action.spawn = dms "audio micmute"; # input mute

    # Brightness
    "XF86MonBrightnessUp".action.spawn = dms "brightness increase";
    "XF86MonBrightnessDown".action.spawn = dms "brightness decrease";

    # Media
    "XF86AudioPlay".action.spawn = dms "mpris playPause";
    "XF86AudioNext".action.spawn = dms "mpris next";
    "XF86AudioPrev".action.spawn = dms "mpris previous";

    # System
    "super+Space".action.spawn = dms "spotlight toggle";
    "super+L".action.spawn = dms "lock lock";
    "super+Grave".action.spawn = dms "dash toggle \"\"";
    "super+V".action.spawn = dms "clipboard toggle";
    "super+Escape".action.spawn = dms "powermenu toggle";

    # Others
    "super+Shift+C".action.spawn = [
      "dms"
      "color"
      "pick"
      "-a"
    ];
    "super+Shift+S".action.spawn = [
      "dms"
      "screenshot"
    ];
  };
}
