{ pkgs, ... }: {
  plugins = with pkgs.vimPlugins; [
    lazy-nvim
  ];

  lazy-plugins = with pkgs.vimPlugins; [
    telescope-fzf-native-nvim
  ];
}
