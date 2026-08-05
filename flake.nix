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
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      hasPrivateConfig = builtins.pathExists ./private && builtins.readDir ./private != { };

      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs hasPrivateConfig;
            flakeRoot = ./.;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit inputs hasPrivateConfig;
                flakeRoot = ./.;
              };
            }
          ];
        };

      hostsDir = ./hosts;
      hostEntries = builtins.readDir hostsDir;
      hostDirs = nixpkgs.lib.filterAttrs (name: type: type == "directory") hostEntries;
      hostNames = builtins.attrNames hostDirs;

      formatterSupportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "i686-darwin"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (hostname: mkHost hostname);
      formatter = nixpkgs.lib.genAttrs formatterSupportedSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
