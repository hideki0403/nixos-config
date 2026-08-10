# nixos-config
## Setup
### Clone
```sh
cd ~
nix-shell -p git --run 'git clone https://github.com/hideki0403/nixos-config.git'
cd nixos-config
```

### Create user
See [account > create user](docs/account.md#create-user) for details.
```sh
sh cli.sh user
```

### Set password
See [account > password policy](docs/account.md#password-policy) for details.

### Create host
```sh
sh cli.sh host
```

### Apply configuration
```sh
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#<hostname>
```
