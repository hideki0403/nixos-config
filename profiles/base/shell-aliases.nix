{ ... }: {
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake \"git+file://$HOME/nixos-config?submodules=1#$(hostname)\"";
    nos = "nh os switch --ask \"git+file://$HOME/nixos-config?submodules=1\" -H \"$(hostname)\" --diff always";
    nos-host = "nh os switch --ask \"git+file://$HOME/nixos-config?submodules=1\" -H ";
    nob = "nh os boot \"git+file://$HOME/nixos-config?submodules=1\" -H \"$(hostname)\"";
    nca = "nh clean all --ask --keep-since 7d --keep 3";
  };
}
