let
  userConfig = import ./identity.nix;
in
{ pkgs, ... }:
{
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.username;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
    ];
  };

  accounts.passwordPolicy.${userConfig.username} = {
    type = "manual";
  };
}
