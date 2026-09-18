{ ... }:
{
  networking.networkmanager.ensureProfiles.profiles.univ-wired = {
    connection = {
      id = "univ-wired";
      type = "802-3-ethernet";
      interface-name = "eth0";
    };

    "802-1x" = {
      eap = "peap";
      phase2-auth = "mschapv2";
      identity = "$NETWORK_WIRED_8021X_UNIV_IDENTITY";
      password = "$NETWORK_WIRED_8021X_UNIV_PASSWORD";
      password-flags = 0;
    };

    ipv4.method = "auto";
    ipv6 = {
      method = "auto";
      addr-gen-mode = "stable-privacy";
    };
  };
}
