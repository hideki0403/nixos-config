{ config, pkgs, ... }:
let
  apps = import ./applications.nix { inherit pkgs; };
  noctalia = cmd: [ "noctalia-shell" "ipc" "call" ] ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.niri.settings.binds = with config.lib.niri.actions; {

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
    "super+Q" = {
      action = close-window;
      repeat = false;
    };
    "super+O" = {
      action = toggle-overview;
      repeat = false;
    };
    "super+B".action = spawn apps.browser;
    "super+Return".action = spawn apps.terminal;
    "super+E".action = spawn apps.fileManager;
    "super+L".action.spawn = noctalia "lockScreen lock";
    "super+Grave".action.spawn = noctalia "controlCenter toggle";
    "super+V".action.spawn = noctalia "launcher clipboard";
    "super+Escape".action.spawn = noctalia "sessionMenu toggle";

    # Tested with ghostty and kitty
    # "super+m".action = spawn apps.terminal [
    #   "--title=spotify_player"
    #   "-e"
    #   "spotify_player"
    # ];

    "super+f".action = fullscreen-window;
    "super+t".action = toggle-window-floating;

    "Print".action.screenshot-screen = {
      write-to-disk = false;
      show-pointer = false;
    };
    "Alt+Print".action.screenshot-window = {
      show-pointer = false;
    };
    # "super+Shift+S".action = screenshot; # Not working?

    "super+Left".action = focus-column-left;
    "super+Right".action = focus-column-right;
    "super+Down".action = focus-workspace-down;
    "super+Up".action = focus-workspace-up;

    "super+MouseMiddle".action = close-window;

    "super+WheelScrollUp" = {
      cooldown-ms = 150;
      action = focus-column-left;
    };
    "super+WheelScrollDown" = {
      cooldown-ms = 150;
      action = focus-column-right;
    };

    "super+Shift+Left".action = move-column-left;
    "super+Shift+Right".action = move-column-right;
    "super+Shift+Down".action = move-column-to-workspace-down;
    "super+Shift+Up".action = move-column-to-workspace-up;

    # "super+1".action = focus-workspace "main";
    # "super+2".action = focus-workspace "browser";
    # "super+3".action = focus-workspace "discord";
    # "super+4".action = focus-workspace "music";
  };
}