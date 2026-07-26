{ lib, hasPrivate, flakeRoot, ... }:

lib.mkIf hasPrivate {
  sops = {
    defaultSopsFile = flakeRoot + "/private/secrets/keys.yaml";
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
