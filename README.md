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

### Set password
Authentication method: `manual`, `file`, `sops`, `none`

#### manual
```sh
sudo passwd <username>
```

#### file
```sh
sh cli.sh password
```
or
```sh
mkdir -p /var/lib/secrets
mkpasswd -m yescrypt > /var/lib/secrets/<USERNAME>
chmod 600 /var/lib/secrets/<USERNAME>
```

#### sops
Set the hashed password in the sops secrets store (`secrets/*.yaml`).

### Create host
```sh
sh cli.sh host
```

### Apply configuration
```sh
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#<hostname>
```
