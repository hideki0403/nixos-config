{ lib, pkgs, ... }:
let
  vimPlugins = import ./plugins.nix { inherit pkgs; };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      typescript-language-server
      bash-language-server
      vim-language-server
    ];
    plugins = vimPlugins.plugins;
    initLua =
      let
        mkEntryFromDrv = drv: if lib.isDerivation drv then { name = "${lib.getName drv}"; path = drv; } else drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (map mkEntryFromDrv vimPlugins.lazy-plugins);
        lazyConfig = builtins.replaceStrings ["@lazy-path@"] ["${lazyPath}"] (builtins.readFile ./lua/init-lazy.lua);
      in
      lib.mkAfter ''
        ${builtins.readFile ./lua/init.lua}
        ${lazyConfig}
        vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}'
      '';
  };
}
