{
  description = "yukineko's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      customConfig = import ./config.nix;

      mkHost =
        hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs customConfig; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs customConfig; };
            }
          ];
        };

      hostsDir = ./hosts;
      hostEntries = builtins.readDir hostsDir;
      hostDirs = nixpkgs.lib.filterAttrs (name: type: type == "directory") hostEntries;
      hostNames = builtins.attrNames hostDirs;
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
        hostname: mkHost hostname customConfig.username
      );
    };
}
