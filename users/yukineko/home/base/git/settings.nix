{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
