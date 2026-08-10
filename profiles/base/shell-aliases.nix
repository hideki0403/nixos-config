{ ... }: {
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake \"git+file://$HOME/nixos-config?submodules=1#$(hostname)\"";
    nos = "nh os switch --ask \"git+file://$HOME/nixos-config?submodules=1\" -H \"$(hostname)\" --diff always";
    nos-host = "nh os switch --ask \"git+file://$HOME/nixos-config?submodules=1\" -H ";
    nca = "nh clean all --ask --keep-since 7d --keep 3";
  };
}
