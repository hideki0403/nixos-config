{ ... }:
{
  imports = [
    ./nixos
    ./sops
    ./tailscale
    ./plymouth
    ./docker
    # ./dms-greeter
  ];
}
