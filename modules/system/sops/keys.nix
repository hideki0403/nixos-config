{ lib, hasPrivateConfig, ... }:

lib.mkIf hasPrivateConfig {
  sops.secrets = {
    "tailscale_authkey" = { };
  };
}
