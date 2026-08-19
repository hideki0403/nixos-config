{
  config,
  lib,
  pkgs,
  inputs,
  mkSymlink,
  ...
}:
lib.mkIf (config.programs.niri.finalConfig != null) {
  # Niriがまだサポートしていない設定はconfig.kdlに書く
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
        // include optional=true "dms/colors.kdl"
        include optional=true "local.kdl"
      ''
    );

  xdg.configFile."niri/local.kdl" = {
    source = mkSymlink ./config.kdl;
  };
}
