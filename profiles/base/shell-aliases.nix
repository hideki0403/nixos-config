{ ... }: {
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake $HOME/nixos-config#$(hostname)";
    nos = "nh os switch --ask $HOME/nixos-config -H $(hostname) --diff always";
    nos-host = "nh os switch --ask $HOME/nixos-config -H ";
    nca = "nh clean all --ask --keep-since 7d --keep 3";
  };
}
