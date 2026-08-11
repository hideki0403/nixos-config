{ config, lib, ... }:
let
  cfg = config.accounts.passwordPolicy;

  sopsAccounts = lib.filterAttrs (_: acc: acc.type == "sops") cfg;
  fileAccounts = lib.filterAttrs (_: acc: acc.type == "file") cfg;
  checkedAccounts = lib.filterAttrs (_: acc: acc.type == "manual" || acc.type == "file") cfg;
  fileAccountsWithPath = lib.filterAttrs (_: acc: acc.hashedPasswordFile != null) fileAccounts;
in
{
  options.accounts.passwordPolicy = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          type = lib.mkOption {
            type = lib.types.enum ["none" "manual" "sops" "file"];
          };

          sopsSecret = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };

          hashedPasswordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
  };

  config = {
    assertions =
      (lib.mapAttrsToList (name: acc: {
        assertion = acc.sopsSecret != null;
        message = ''accounts.passwordPolicy.${name}: If the type is "sops", sopsSecret must be specified. See 'docs/account.md' for details.'';
      }) sopsAccounts)
      ++ (lib.mapAttrsToList (name: acc: {
        assertion = acc.hashedPasswordFile != null;
        message = ''accounts.passwordPolicy.${name}: If the type is "file", hashedPasswordFile must be specified. See 'docs/account.md' for details.'';
      }) fileAccounts);

    system.preSwitchChecks = lib.optionalAttrs (checkedAccounts != { }) {
      accountsCanLogin = ''
        missing=()

        password_is_set() {
          local user="$1" name pw
          if [ ! -r /etc/shadow ]; then
            {
              echo "Error: /etc/shadow is not readable. Cannot verify account passwords."
              echo "  If you are installing for the first time with 'nixos-install', you can skip this check by setting 'NIXOS_NO_CHECK=1'."
              echo "  See 'docs/account.md' for details."
            } >&2
            exit 1
          fi

          while IFS=: read -r name pw _ || [ -n "$name" ]; do
            if [ "$name" = "$user" ]; then
              case "$pw" in
                '$'*) return 0 ;;
                *) return 1 ;;
              esac
            fi
          done < /etc/shadow

          return 1
        }

        check_account() {
          local name="$1" initial="$2"

          if password_is_set "$name"; then
            return 0
          fi

          if [ -n "$initial" ] && [ -s "$initial" ]; then
            return 0
          fi

          missing+=("$name")
        }

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: acc:
            "check_account ${lib.escapeShellArg name} ${
              lib.escapeShellArg (if acc.hashedPasswordFile == null then "" else acc.hashedPasswordFile)
            }"
          ) checkedAccounts
        )}

        if [ ''${#missing[@]} -ne 0 ]; then
          {
            echo "Error: cannot apply this configuration. The following accounts may become unable to log in."
            echo ""
            printf -- '- %s\n' "''${missing[@]}"
            echo ""
            echo "See 'docs/account.md' for details."
          } >&2
          exit 1
        fi
      '';
    };

    sops.secrets = lib.listToAttrs (
      map (acc: {
        name = acc.sopsSecret;
        value = {
          neededForUsers = true;
        };
      }) (builtins.filter (acc: acc.sopsSecret != null) (builtins.attrValues sopsAccounts))
    );

    systemd.tmpfiles.rules = lib.optional (
      fileAccountsWithPath != { }
    ) "d /var/lib/secrets 0711 root root -";

    users.users = lib.mapAttrs (
      _: acc:
      if acc.type == "sops" && acc.sopsSecret != null then
        { hashedPasswordFile = config.sops.secrets.${acc.sopsSecret}.path; }
      else if acc.type == "file" then
        { hashedPasswordFile = acc.hashedPasswordFile; }
      else
        { }
    ) cfg;
  };
}
