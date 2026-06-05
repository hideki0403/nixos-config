{ pkgs, customConfig, ... }:
{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +5";
  };

  # User
  users.users.${customConfig.username} = {
    isNormalUser = true;
    description = customConfig.username;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
