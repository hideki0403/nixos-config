{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./fish/init.fish;

    # functions = {
    #   __auto_ls = {
    #     body = "ls";
    #     onVariable = "PWD";
    #   };
    # };

    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
  };

  home.packages = with pkgs; [
    eza
    bat
    fd
  ];
}
