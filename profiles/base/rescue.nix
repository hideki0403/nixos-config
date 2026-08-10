{ flakeConfig, ... }:
{
  # 締め出し防止用 詳細は`docs/account.md`を参照
  users.users.root.openssh.authorizedKeys.keys = [ flakeConfig.rescueSSHKey ];
}
