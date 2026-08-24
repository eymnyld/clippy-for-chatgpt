#!/usr/bin/env bash
set -euo pipefail

force=0
if [[ ${1:-} == "--force" ]]; then
  force=1
  shift
fi
if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--force]" >&2
  exit 64
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
plugin_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_dir="$plugin_dir/assets/pet/clippy"
codex_root="${CODEX_HOME:-${HOME}/.codex}"
target_dir="$codex_root/pets/clippy"

expected_sprite="96b04a0a1a82060e663a3b17c914630d47f66b6f80dad425a6c0f5c67c642ea5"
expected_pet="e18f38295dba206ba9cb69afdd462d472c8e0787ad38dc302bf02c2371c4b88a"

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    echo "A SHA-256 utility (shasum or sha256sum) is required." >&2
    return 127
  fi
}

verify_hash() {
  local path=$1
  local expected=$2
  local actual
  actual=$(sha256_file "$path")
  if [[ "$actual" != "$expected" ]]; then
    echo "Checksum mismatch: $path" >&2
    return 1
  fi
}

verify_hash "$source_dir/spritesheet.webp" "$expected_sprite"
verify_hash "$source_dir/pet.json" "$expected_pet"

if [[ -f "$target_dir/spritesheet.webp" && -f "$target_dir/pet.json" ]] && \
   cmp -s "$source_dir/spritesheet.webp" "$target_dir/spritesheet.webp" && \
   cmp -s "$source_dir/pet.json" "$target_dir/pet.json"; then
  echo "Clippy is already installed and verified at $target_dir"
  exit 0
fi

if [[ -e "$target_dir/spritesheet.webp" || -e "$target_dir/pet.json" ]] && [[ $force -ne 1 ]]; then
  echo "A different Clippy package already exists at $target_dir" >&2
  echo "Re-run with --force only after approving replacement." >&2
  exit 2
fi

mkdir -p "$target_dir"
tmp_sprite=$(mktemp "$target_dir/.spritesheet.webp.XXXXXX")
tmp_pet=$(mktemp "$target_dir/.pet.json.XXXXXX")
cleanup() {
  [[ -n ${tmp_sprite:-} ]] && rm -f -- "$tmp_sprite"
  [[ -n ${tmp_pet:-} ]] && rm -f -- "$tmp_pet"
  return 0
}
trap cleanup EXIT HUP INT TERM

cp "$source_dir/spritesheet.webp" "$tmp_sprite"
cp "$source_dir/pet.json" "$tmp_pet"
verify_hash "$tmp_sprite" "$expected_sprite"
verify_hash "$tmp_pet" "$expected_pet"
chmod 0644 "$tmp_sprite" "$tmp_pet"
mv -f "$tmp_sprite" "$target_dir/spritesheet.webp"
tmp_sprite=""
mv -f "$tmp_pet" "$target_dir/pet.json"
tmp_pet=""

verify_hash "$target_dir/spritesheet.webp" "$expected_sprite"
verify_hash "$target_dir/pet.json" "$expected_pet"
echo "Installed and verified Clippy at $target_dir"
