let
  userConfig = import ../../../identity.nix;
in
{ config, lib, ... }:
let
  cfg = config.tailnet;

  tailnetDefaults = {
    UserKnownHostsFile = "~/.ssh/known_hosts.tailnet ~/.config/tailscale/ssh_known_hosts";
    StrictHostKeyChecking = "accept-new";
  };

  mkTailnetHost =
    _: host:
    tailnetDefaults
    // {
      HostName = host.address;
      User = if host.user != null then host.user else cfg.user;
    }
    // lib.optionalAttrs (host.port != null) { Port = host.port; }
    // host.settings;
in
{
  options.tailnet = {
    user = lib.mkOption {
      type = lib.types.str;
      default = userConfig.username;
    };

    hosts = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            address = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };

            user = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            port = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
            };

            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
            };
          };
        }
      );
    };
  };

  config = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ServerAliveInterval = 30;
          ServerAliveCountMax = 3;
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          SetEnv = {
            LANG = "C.UTF-8";
            LC_CTYPE = "C.UTF-8";
            TERM = "xterm-256color";
          };
        };
      }
      // lib.mapAttrs mkTailnetHost cfg.hosts;
    };

    # FHS環境で壊れる問題があるのを直す
    # ref: https://github.com/nix-community/home-manager/issues/322
    home.file.".ssh/config".enable = false;

    home.activation.sshConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -p $VERBOSE_ARG "$HOME/.ssh"
      run chmod 700 $VERBOSE_ARG "$HOME/.ssh"
      run rm -f $VERBOSE_ARG "$HOME/.ssh/config"
      run install -m600 $VERBOSE_ARG ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
    '';
  };
}
