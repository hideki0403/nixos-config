{
  pkgs,
  lib,
  inputs,
  system,
  flakeRoot,
}:
{
  vm = import ./accounts/vm.nix {
    inherit pkgs inputs flakeRoot;
  };

  accounts-eval = import ./accounts/eval.nix {
    inherit pkgs lib inputs system flakeRoot;
  };
}
