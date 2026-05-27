{ config, lib, pkgs, inputs, ... }:
lib.mkIf (config.programs.niri.finalConfig != null) {
  # Niriがまだサポートしていない設定を直接書き込む
  # https://github.com/sodiboo/niri-flake/issues/1721#issuecomment-4428164218
  xdg.configFile.niri-config.source =
    let
      inherit (inputs.niri.lib.internal) validated-config-for;
      inherit (config.programs.niri) finalConfig package;
    in
    lib.mkForce (
      validated-config-for pkgs package ''
        ${finalConfig}

        // include optional=true "noctalia.kdl"
        include optional=true "dms/colors.kdl"

        // --- General settings ---
        window-rule {
          geometry-corner-radius 16

          clip-to-geometry true

          background-effect {
            blur true
            xray false
          }

          focus-ring {
            width 2
          }
        }

        blur {
          passes 2        // more passes = stronger blur (default: 3)
          offset 3.0      // sample distance per pass (default: 3.0)
          noise 0.03      // grain overlay (default: 0.02)
          saturation 1.0  // color saturation boost (default: 1.5)
        }

        recent-windows {
          binds {
              Alt+Tab         { next-window; }
              Alt+Shift+Tab   { previous-window; }
          }
        }

        // --- Noctalia ---
        layer-rule {
          match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"
          background-effect {
            xray false
            blur true
          }
        }

        layer-rule {
          match namespace="^noctalia-(wallpaper|overview).*$"
          place-within-backdrop true
        }

        // --- DMS ---
        // ref: https://danklinux.com/docs/dankmaterialshell/compositors#niri-configuration
        layer-rule {
            match namespace="^dms:clipboard$"
            block-out-from "screencast"
        }

        layer-rule {
            match namespace="^quickshell$"
            place-within-backdrop true
        }

        window-rule {
            match app-id=r#"^org\.gnome\."#
            draw-border-with-background false
        }

        window-rule {
            match app-id=r#"^org\.wezfurlong\.wezterm$"#
            match app-id="Alacritty"
            match app-id="zen"
            match app-id="com.mitchellh.ghostty"
            match app-id="kitty"
            draw-border-with-background false
        }

        window-rule {
            match is-active=false
            focus-ring {
                width 0
            }
        }

        // Open DMS windows as floating by default
        window-rule {
            match app-id=r#"org.quickshell$"#
            open-floating true
        }
      ''
    );
}
