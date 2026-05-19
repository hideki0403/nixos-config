{ ... }:
{
  programs.git = {
    enable = true;
    includes = [
      { path = "~/.gitconfig.local"; }
    ];
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
