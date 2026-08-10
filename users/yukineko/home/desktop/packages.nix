{ pkgs, ... }: {
  home.packages = with pkgs; [
    wakeonlan
    lazygit
  ];
}
