#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash deno whois
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/f5c082a40f7571c266e74e80ae2e68aadd8a9fc7.tar.gz
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
