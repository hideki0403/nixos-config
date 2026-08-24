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
      flakeConfig = import ./config.nix;

      privateRoot = ./private/nix;

      privateModule =
        path:
        let
          target = privateRoot + "/${path}";
        in
        nixpkgs.lib.optional (hasPrivateConfig && builtins.pathExists target) target;

      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              hasPrivateConfig
              flakeConfig
              privateModule
              ;
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
                inherit inputs hasPrivateConfig privateModule;
                flakeRoot = ./.;
              };
            }
          ];
        };

      hostsDir = ./hosts;
      hostEntries = builtins.readDir hostsDir;
      hostDirs = nixpkgs.lib.filterAttrs (name: type: type == "directory") hostEntries;
      hostNames = builtins.attrNames hostDirs;

      testSupportedSystems = [
        "x86_64-linux"
      ];

      formatterSupportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "i686-darwin"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (hostname: mkHost hostname);
      checks = nixpkgs.lib.genAttrs testSupportedSystems (
        system:
        import ./tests/nix {
          inherit inputs system;
          inherit (nixpkgs) lib;
          pkgs = nixpkgs.legacyPackages.${system};
          flakeRoot = ./.;
        }
      );
      formatter = nixpkgs.lib.genAttrs formatterSupportedSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
