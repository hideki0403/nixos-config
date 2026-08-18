{
  config,
  options,
  lib,
  flakeRoot,
  ...
}:
let
  cfg = config.symlink;
in
{
  options.symlink.directory = lib.mkOption {
    type = lib.types.str;
    default = "nixos-config"; # ~/nixos-config
  };

  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      (
        { config, ... }:
        {
          _module.args.mkSymlink =
            target:
            config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${cfg.directory}/${lib.removePrefix "${toString flakeRoot}/" (toString target)}";
        }
      )
    ];
  };
}
