{ ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = false;

    # 22番はTailscale SSHが受け付けるため2222番も開けておく
    ports = [
      22
      2222
    ];

    settings.PermitRootLogin = "prohibit-password";
  };
}
