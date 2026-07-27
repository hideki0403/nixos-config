{ ... }: {
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake $HOME/nixos-config#$(hostname)";
  };
}
