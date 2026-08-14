{ flakeConfig, ... }:
{
  # TODO: nh側の実装に移動する
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than +5";
  # };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = flakeConfig.caches.substituters;
    trusted-public-keys = flakeConfig.caches.trustedPublicKeys;
  };
}
