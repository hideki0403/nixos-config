{
  rescueSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIADrNnD7BJcD2trpVmPFLnn4d375s+vqTxgSBBz7Rj+";

  caches = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
      "https://yukineko.cachix.org"
    ];
    trustedPublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "yukineko.cachix.org-1:bAzkCf3lyUv7IpxH8qSL0bFw/R/8YKXk+eJDze18Dvg="
    ];
  };
}
