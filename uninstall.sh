#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$repo_dir/plugins/clippy-for-chatgpt/scripts/uninstall_clippy_pet.sh" "$@"
