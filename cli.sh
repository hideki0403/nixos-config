#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash deno whois
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/c5c4a43b0e8056328ec4529f735cabdb8f1942bb.tar.gz
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
