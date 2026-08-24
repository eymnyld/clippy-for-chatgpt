#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} != "--yes" || $# -ne 1 ]]; then
  echo "Usage: $0 --yes" >&2
  exit 64
fi

codex_root="${CODEX_HOME:-${HOME}/.codex}"
target_dir="$codex_root/pets/clippy"

if [[ ! -d "$target_dir" ]]; then
  echo "Clippy is not installed at $target_dir"
  exit 0
fi

rm -f -- "$target_dir/pet.json" "$target_dir/spritesheet.webp"
if rmdir "$target_dir" 2>/dev/null; then
  echo "Removed Clippy from $target_dir"
else
  echo "Removed Clippy pet files; preserved unexpected files in $target_dir"
fi
