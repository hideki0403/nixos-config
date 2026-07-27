{ ... }: {
  xdg.configFile."wezterm/wezterm.lua".force = true;

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
