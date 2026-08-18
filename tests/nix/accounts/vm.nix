{
  pkgs,
  inputs,
  flakeRoot,
}:
let
  passwords = {
    alice = "alice-password";
    yuzuha = "yuzuha-password";
    remielle = "remielle-password";
    zhao = "zhao-password";
  };

  hashedPasswordFile = "/var/lib/secrets/yuzuha";
  sopsSecret = "hashed_pw_remielle";
  ageKeyFile = "/var/lib/sops-nix/key.txt";

  scenarios = {
    manual = {
      accounts.passwordPolicy.alice.type = "manual";
      accounts.passwordPolicy.zhao.type = "manual";
    };

    file = {
      users.users.yuzuha.isNormalUser = true;
      accounts.passwordPolicy.yuzuha = {
        type = "file";
        inherit hashedPasswordFile;
      };
    };

    sops = {
      users.users.remielle.isNormalUser = true;
      accounts.passwordPolicy.remielle = {
        type = "sops";
        inherit sopsSecret;
      };
    };

    none = {
      users.users.belle.isNormalUser = true;
      accounts.passwordPolicy.belle.type = "none";
    };
  };
in
pkgs.testers.runNixOSTest {
  name = "accounts-password-policy";

  node.pkgsReadOnly = false;
  node.specialArgs = {
    inherit inputs flakeRoot;
    hasPrivateConfig = false;
    privateModule = _: [ ];
    flakeConfig = import (flakeRoot + "/config.nix");
  };

  nodes.machine =
    { lib, pkgs, ... }:
    {
      imports = [
        (flakeRoot + "/profiles/base")
        inputs.sops-nix.nixosModules.sops
      ];

      boot.loader.grub.enable = lib.mkForce false;
      services.tailscale.enable = lib.mkForce false;

      virtualisation.memorySize = 2048;
      environment.systemPackages = with pkgs; [
        pamtester
        mkpasswd
      ];

      users.mutableUsers = true;
      users.users.alice.isNormalUser = true;
      users.users.zhao.isNormalUser = true;

      sops.defaultSopsFile = ../fixtures/secrets.yaml;
      sops.age.keyFile = ageKeyFile;
      sops.age.generateKey = false;

      boot.postBootCommands = "install -Dm600 ${../fixtures/age-key.txt} ${ageKeyFile}";

      specialisation = lib.mapAttrs (_: configuration: { inherit configuration; }) scenarios // {
        all.configuration.imports = lib.attrValues scenarios;
      };
    };

  testScript =
    { nodes, ... }:
    let
      toplevel = nodes.machine.system.build.toplevel;
    in
    # python
    ''
      def switch(name, action="check", environment="", expect_success=True):
          command = f"{environment} ${toplevel}/specialisation/{name}/bin/switch-to-configuration {action} 2>&1"
          return machine.succeed(command) if expect_success else machine.fail(command)

      def assert_contains(output, expected):
          assert expected in output, f"expected {expected!r} in:\n{output}"

      def assert_lacks(output, unexpected):
          assert unexpected not in output, f"expected no {unexpected!r} in:\n{output}"

      def set_password(user, password):
          machine.succeed(f"(echo '{password}'; echo '{password}') | passwd {user}")

      def authenticate(user, password, expect_success=True):
          command = f"echo '{password}' | pamtester login {user} authenticate"
          machine.succeed(command) if expect_success else machine.fail(command)

      machine.wait_for_unit("multi-user.target")

      # --- pre-switch check ---

      with subtest("manual: パスワード未設定の場合はコケる"):
          output = switch("manual", expect_success=False)
          assert_contains(output, "cannot apply this configuration")
          assert_contains(output, "- alice")
          assert_contains(output, "- zhao")

      with subtest("manual: パスワードが設定されていれば通る"):
          set_password("alice", "${passwords.alice}")
          set_password("zhao", "${passwords.zhao}")
          switch("manual")

      with subtest("manual: ロックされたアカウントがある場合はコケる"):
          machine.succeed("passwd -l alice")
          output = switch("manual", expect_success=False)
          assert_contains(output, "- alice")
          assert_lacks(output, "- zhao")
          machine.succeed("passwd -u alice")
          switch("manual")

      with subtest("manual: /etc/shadow に存在しないアカウントがある場合はコケる"):
          machine.succeed("cp /etc/shadow /tmp/shadow.bak")
          machine.succeed("sed -i '/^zhao:/d' /etc/shadow")
          output = switch("manual", expect_success=False)
          assert_contains(output, "- zhao")
          assert_lacks(output, "- alice")
          machine.succeed("cp /tmp/shadow.bak /etc/shadow")
          switch("manual")

      with subtest("/etc/shadow が読み取れない場合はエラーになる"):
          machine.succeed("mv /etc/shadow /tmp/shadow.hidden")
          output = switch("manual", expect_success=False)
          assert_contains(output, "/etc/shadow is not readable")
          machine.succeed("mv /tmp/shadow.hidden /etc/shadow")

      with subtest("file: hashedPasswordFileが存在しなければコケる"):
          output = switch("file", expect_success=False)
          assert_contains(output, "- yuzuha")

      with subtest("file: hashedPasswordFileが空ならコケる"):
          machine.succeed("install -Dm600 /dev/null ${hashedPasswordFile}")
          output = switch("file", expect_success=False)
          assert_contains(output, "- yuzuha")

      with subtest("NIXOS_NO_CHECK=1 でチェックをスキップできる"):
          switch("file", environment="NIXOS_NO_CHECK=1")

      with subtest("file: hashedPasswordFileが配置されていれば通る"):
          machine.succeed("echo '${passwords.yuzuha}' | mkpasswd -m yescrypt -s > ${hashedPasswordFile}")
          switch("file")

      with subtest("sops, none の場合は常に通る"):
          switch("sops")
          switch("none")

      # --- switch check ---

      with subtest("全ての認証方法を含む構成に切り替えられる"):
          switch("all")
          switch("all", action="test")

      with subtest("manual: 設定したパスワードで認証できる"):
          authenticate("alice", "${passwords.alice}")
          authenticate("alice", "wrong-password", expect_success=False)

      with subtest("file: hashedPasswordFileのパスワードで認証できる"):
          machine.succeed("grep -E '^yuzuha:\\$' /etc/shadow")
          authenticate("yuzuha", "${passwords.yuzuha}")
          authenticate("yuzuha", "wrong-password", expect_success=False)

      with subtest("sops: secretに設定されたパスワードで認証できる"):
          machine.succeed("test -e /run/secrets-for-users/${sopsSecret}")
          machine.succeed("grep -E '^remielle:\\$' /etc/shadow")
          authenticate("remielle", "${passwords.remielle}")
          authenticate("remielle", "wrong-password", expect_success=False)

      with subtest("none: パスワード認証が無効になっている"):
          machine.succeed("grep -E '^belle:!' /etc/shadow")
          authenticate("belle", "${passwords.remielle}", expect_success=False)

      with subtest("TTYから実際にログインできる"):
          machine.send_key("alt-f2")
          machine.wait_until_succeeds("[ $(fgconsole) = 2 ]")
          machine.wait_for_unit("getty@tty2.service")
          machine.wait_until_tty_matches("2", "login: ")
          machine.send_chars("alice\n")
          machine.wait_until_tty_matches("2", "login: alice")
          machine.wait_until_succeeds("pgrep login")
          machine.wait_until_tty_matches("2", "Password: ")
          machine.send_chars("${passwords.alice}\n")
          machine.wait_until_succeeds("pgrep -u alice bash")
          machine.send_chars("exit\n")
          machine.wait_until_fails("pgrep -u alice bash")
          machine.send_key("alt-f1")

      with subtest("チェックをスキップした場合にログインできなくなる"):
          machine.succeed("usermod -p '!' alice")
          output = switch("all", expect_success=False)
          assert_contains(output, "- alice")
          switch("all", action="test", environment="NIXOS_NO_CHECK=1")
          authenticate("alice", "${passwords.alice}", expect_success=False)
    '';
}
