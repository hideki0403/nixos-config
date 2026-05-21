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

        include optional=true "noctalia.kdl"

        window-rule {
          background-effect {
            blur true
            xray false
          }
        }

        layer-rule {
          match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"
          background-effect {
            xray false
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
      ''
    );
}