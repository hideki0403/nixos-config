{
  pkgs,
  lib,
  inputs,
  system,
  flakeRoot,
}:
let
  evalConfig =
    module:
    (inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs flakeRoot;
        hasPrivateConfig = false;
        flakeConfig = import (flakeRoot + "/config.nix");
      };
      modules = [
        (flakeRoot + "/profiles/base/accounts.nix")
        inputs.sops-nix.nixosModules.sops
        {
          nixpkgs.hostPlatform = system;
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
          system.stateVersion = "25.11";

          users.users.testuser.isNormalUser = true;
          sops.defaultSopsFile = ../fixtures/secrets.yaml;
        }
        module
      ];
    }).config;

  failedAssertions =
    config:
    map (assertion: assertion.message) (
      lib.filter (
        assertion: !assertion.assertion && lib.hasPrefix "accounts.passwordPolicy." assertion.message
      ) config.assertions
    );

  hasMessage =
    config: expected: lib.any (message: lib.hasInfix expected message) (failedAssertions config);

  sopsSecret = "hashed_pw_testuser";
  hashedPasswordFile = "/var/lib/secrets/testuser";

  configs = {
    manual = evalConfig {
      accounts.passwordPolicy.testuser.type = "manual";
    };
    none = evalConfig {
      accounts.passwordPolicy.testuser.type = "none";
    };
    sops = evalConfig {
      accounts.passwordPolicy.testuser = {
        type = "sops";
        inherit sopsSecret;
      };
    };
    file = evalConfig {
      accounts.passwordPolicy.testuser = {
        type = "file";
        inherit hashedPasswordFile;
      };
    };
    sopsWithoutSecret = evalConfig {
      accounts.passwordPolicy.testuser.type = "sops";
    };
    fileWithoutPath = evalConfig {
      accounts.passwordPolicy.testuser.type = "file";
    };
  };

  checks = [
    {
      name = "sops: sopsSecretが指定されていなければコケる";
      ok = hasMessage configs.sopsWithoutSecret ''If the type is "sops", sopsSecret must be specified'';
    }
    {
      name = "file: hashedPasswordFileが指定されていなければコケる";
      ok = hasMessage configs.fileWithoutPath ''If the type is "file", hashedPasswordFile must be specified'';
    }
    {
      name = "typeが指定されていれば通る";
      ok = lib.all (config: failedAssertions config == [ ]) (
        with configs;
        [
          manual
          none
          sops
          file
        ]
      );
    }
    {
      name = "sops: hashedPasswordFileの値がsopsのsecretへのパスになっている";
      ok =
        configs.sops.users.users.testuser.hashedPasswordFile
        == configs.sops.sops.secrets.${sopsSecret}.path;
    }
    {
      name = "sops: secretがneededForUsersになっている";
      ok = configs.sops.sops.secrets.${sopsSecret}.neededForUsers;
    }
    {
      name = "file: hashedPasswordFileの値が指定したパスになっている";
      ok = configs.file.users.users.testuser.hashedPasswordFile == hashedPasswordFile;
    }
    {
      name = "file: /var/lib/secrets が作成される";
      ok = lib.any (rule: lib.hasPrefix "d /var/lib/secrets " rule) configs.file.systemd.tmpfiles.rules;
    }
    {
      name = "manual, noneの場合にはhashedPasswordFileが空になっている";
      ok = lib.all (config: config.users.users.testuser.hashedPasswordFile == null) [
        configs.manual
        configs.none
      ];
    }
    {
      name = "manual, fileがあればpre-switch checkが生成される";
      ok = lib.all (config: config.system.preSwitchChecks ? accountsCanLogin) [
        configs.manual
        configs.file
      ];
    }
    {
      name = "none, sopsのみの場合にはpre-switch checkが生成されない";
      ok = lib.all (config: !(config.system.preSwitchChecks ? accountsCanLogin)) [
        configs.none
        configs.sops
      ];
    }
  ];

  failed = lib.filter (check: !check.ok) checks;
in
if failed != [ ] then
  throw "accounts eval checks failed:\n${
    lib.concatMapStringsSep "\n" (check: "- ${check.name}") failed
  }"
else
  pkgs.runCommand "accounts-eval-checks" { } ''
    ${lib.concatMapStringsSep "\n" (check: "echo ${lib.escapeShellArg "ok: ${check.name}"}") checks}
    touch $out
  ''
