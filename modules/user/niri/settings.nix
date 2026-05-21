{ pkgs, inputs, ... }:
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
    x11.enable = true;
    gtk.enable = true;
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/%Y-%M-%D_%H%M%S.png";
      hotkey-overlay.skip-at-startup = true;

      layout = {
        background-color = "transparent";
        shadow = {
          enable = true;
          offset = {
            x = 0;
            y = 0;
          };
        };
      };

      input = {
        # focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = true;
        touchpad = {
          tap = true;
          scroll-method = "two-finger";
          accel-profile = "adaptive";
          accel-speed = 0;
          scroll-factor = 0.2;
        };
      };

      outputs = {
        "eDP-1" = {
          scale = 1.25;
        };

        # "HDMI-A-1" = {
          # scale = 1;
          # mode = "1920x1080@60";
        # };
      };

      workspaces = {
        # TODO
      };

      overview = {
        workspace-shadow.enable = true;
      };

      environment = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        DISPLAY = ":0";
      };

      debug.honor-xdg-activation-with-invalid-serial = [ ]; # Enable for noctalia
    };
  };
}
