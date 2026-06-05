{ ... }: {
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };
}
