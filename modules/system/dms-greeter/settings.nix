{ ... }: {
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
  };
}
