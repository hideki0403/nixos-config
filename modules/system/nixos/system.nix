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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
