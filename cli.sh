#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash deno whois
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/9f78f44a87948854445dae0b6bf82b2e87e4efb5.tar.gz
#@nixpkgs: nixos-26.05

set -euo pipefail

root="$(cd -- "$(dirname -- "$0")" && pwd)"

exec deno run \
  --config "$root/cli/deno.json" \
  --allow-read \
  --allow-write \
  --allow-run \
  --allow-sys=uid \
  "$root/cli/entrypoint.ts" \
  "$@"
