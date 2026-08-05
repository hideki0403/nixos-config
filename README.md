# nixos-config
## Setup
### Clone
```sh
cd ~
nix-shell -p git --run 'git clone https://github.com/hideki0403/nixos-config.git'
cd nixos-config
```

### Create user
```sh
sh cli.sh user
```

### Create host
```sh
sh cli.sh host
```

### Apply configuration
```sh
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#<hostname>
```
