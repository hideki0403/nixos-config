#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash deno whois
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/3068c73a96a6979ee8e72e7196577d0bd842d412.tar.gz
#@nixpkgs: nixos-26.11

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
