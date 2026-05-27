{ pkgs, ... }:
let
  noctalia = cmd: [ "noctalia-shell" "ipc" "call" ] ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.niri.settings.binds = {
    # Volume
    "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase"; # output increase
    "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease"; # output decrease
    "XF86AudioMute".action.spawn = noctalia "volume muteOutput"; # output mute
    "shift+XF86AudioRaiseVolume".action.spawn = noctalia "volume increaseInput"; # input increase
    "shift+XF86AudioLowerVolume".action.spawn = noctalia "volume decreaseInput"; # input decrease
    "shift+XF86AudioMute".action.spawn = noctalia "volume muteInput"; # input mute
    "control+XF86AudioMute".action.spawn = noctalia "volume togglePanel"; # open volume panel

    # Media
    "XF86AudioPlay".action.spawn = noctalia "media playPause";
    "XF86AudioNext".action.spawn = noctalia "media next";
    "XF86AudioPrev".action.spawn = noctalia "media previous";

    # System
    "super+Space".action.spawn = noctalia "launcher toggle";
    "super+L".action.spawn = noctalia "lockScreen lock";
    "super+Grave".action.spawn = noctalia "controlCenter toggle";
    "super+V".action.spawn = noctalia "launcher clipboard";
    "super+Escape".action.spawn = noctalia "sessionMenu toggle";
  };
}
