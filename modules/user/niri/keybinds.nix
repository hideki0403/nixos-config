{ config, pkgs, ... }:
let
  apps = import ./applications.nix { inherit pkgs; };
in
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
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

    # "super+F".action = maximize-window-to-edges;
    # "super+Shift+F".action = expand-column-to-available-width;
    "super+F".action = expand-column-to-available-width;
    "super+Shift+F".action = maximize-window-to-edges;
    "super+Ctrl+F".action = fullscreen-window;

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

    "super+Minus".action = set-column-width "-5%";
    "super+Equal".action = set-column-width "+5%";
    "super+Shift+Minus".action = set-window-height "-10%";
    "super+Shift+Equal".action = set-window-height "+10%";
  };
}
