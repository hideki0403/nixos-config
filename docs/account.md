# Account
ユーザーアカウントの作成と管理方法もろもろについて  
エラーメッセージ等からこのドキュメントに飛んできた場合は[「困ったときは」](#troubleshooting)を参照してください。

## はじめに
このflakeでは全ユーザーが`users.mutableUsers = true`であることを前提に管理を行っています。  

## ユーザーの作成 <a id="create-user"></a>
ユーザーはCLI (`./cli.sh user`) から作成できます。  
CLI経由で作成を行わない場合は `users/yukineko` を参照してください。  

### `accounts.passwordPolicy`について <a id="password-policy"></a>
締め出しを防止するため、原則としてユーザーのパスワードは以下の方法で設定します。
```nix
accounts.passwordPolicy.<name> = {
  type = "manual";
};
```

typeに設定できる値は以下の通りです。
| Value | Description |
| --- | --- |
| [`manual`](#type-manual) | `passwd` 経由で設定する (config側からは設定しない) |
| [`sops`](#type-sops) | sops-nixのsecretを使用する |
| [`file`](#type-file) | 事前に配置された `hashedPasswordFile` を使用する |
| [`none`](#type-none) | パスワード認証を無効化する |

#### `manual` <a id="type-manual"></a>
`nixos-rebuild`する前に`passwd`でパスワードを設定しておく必要があります。

#### `sops` <a id="type-sops"></a>
sops-nixのsecretに設定された`hashedPassword`を参照します。  
事前にsops-nixのsecretを読み取れる状態にしておく (またsecretにhashedPasswordを設定しておく) 必要があり、対象のsecretは以下のようにして指定します。
```nix
accounts.passwordPolicy.<name> = {
  type = "sops";
  sopsSecret = "hogefuga";
};
```
  
> [!WARNING]
> sops-nixのsecretが存在するかどうかのチェックは行えないため、締め出されないように気をつけてください。  
> `manual`や`file`などが指定された、確実にログインできるアカウントがある状態で使用することをおすすめします。
  
このオプションは `users.users.<name>.hashedPasswordFile = config.sops.secrets.<secret>.path;`と同等です。  
  
#### `file` <a id="type-file"></a>
ディスク上に配置された`hashedPasswordFile`を参照します。  
`nixos-rebuild`前に`hashedPassword`を書き込んだファイルを配置しておく必要があり、パスは以下のようにして指定します。
```nix
accounts.passwordPolicy.<name> = {
  type = "file";
  hashedPasswordFile = "/var/lib/secrets/<name>";
};
```
  
以下2つの方法で`hashedPasswordFile`を作成できます。
1. `./cli.sh password`から作成する
2. 自力で作成する
```bash
$ sudo mkpasswd -m yescrypt > /var/lib/secrets/<name>
$ sudo chmod 600 /var/lib/secrets/<name>
```

このオプションは `users.users.<name>.hashedPasswordFile = "/var/lib/secrets/<name>";`と同等です。  

#### `none` <a id="type-none"></a>
設定事項はありません。  

## 認証方法の検証について
このflakeではパスワード未設定によるアカウント締め出しを防止するため、flake適用前に各ユーザーの認証方法が機能するかをチェックする仕組みがあります。[^1]  
[^1]: 実装については`profiles/base/accounts.nix`を参照してください。  

`nixos-rebuild`を実行した際にエラーが出た場合はログインできないアカウントが存在する可能性があるため、上にあるpasswordPolicyを再確認してください。  

## 初回インストール時にエラーが出る場合 <a id="first-install-error"></a>
`manual`など、一部の認証方法は初回インストールのタイミングで認証情報を用意できないことがあります。  
その場合には以下の方法で認証をスキップすることができます。
```bash
$ NIXOS_NO_CHECK=1 nixos-install --flake <path>#<host>
```

> [!warning]
> `nixos-install`完了時にrootパスワードの設定があります。
> 設定後にrootでログインしてから、パスワード未設定のユーザーのパスワードを設定してください。

## 困ったときは <a id="troubleshooting"></a>
### エラーが出た
- `Error: cannot apply this configuration. The following accounts may become unable to log in.`
  - 適用しようとしているhostsに含まれる、いずれかのアカウントにパスワードが設定されていない可能性があります。
  - 解決方法については[`manual`](#type-manual)または[`file`](#type-file)を参照してください
- `Error: /etc/shadow is not readable. Cannot verify account passwords.`
  - 初回インストール時 (恐らく `nixos-install`) にパスワード検証に失敗している可能性があります。
  - 解決方法については[「初回インストール時にエラーが出る場合」](#first-install-error)を参照してください
- `accounts.passwordPolicy.<name>: If the type is "sops", sopsSecret must be specified.`
  - `accounts.passwordPolicy.<name>`のtypeがsopsに指定されているものの、`sopsSecret`が定義されていない可能性があります。
  - 対象のアカウントのpasswordPolicyを再確認してください。
  - 設定については[`sops`](#type-sops)を参照してください
- `accounts.passwordPolicy.<name>: If the type is "file", hashedPasswordFile must be specified.`
  - `accounts.passwordPolicy.<name>`のtypeがfileに指定されているものの、`hashedPasswordFile`が定義されていない可能性があります。
  - 対象のアカウントのpasswordPolicyを再確認してください。
  - 設定については[`file`](#type-file)を参照してください

### アカウントにログインできなくなった
`config.nix`に登録されている鍵を用いてSSH経由でrootにログインして復旧できます。
