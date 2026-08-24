---
name: install-clippy-pet
description: Install, update, verify, or remove the bundled Clippy v2 pet for the Codex desktop app. Use when the user asks to import, install, check, update, or uninstall this repository's Clippy pet; do not use for unrelated pets or general plugin management.
---

# Install Clippy Pet

The plugin bundles the approved package at `../../assets/pet/clippy/`. It contains `pet.json` and `spritesheet.webp`; installation is local and requires no connector, API key, or network access.

## Install or update

1. Resolve the skill directory, then use the installer for the current OS:
   - macOS/Linux: `../../scripts/install_clippy_pet.sh`
   - Windows PowerShell: `../../scripts/install-clippy-pet.ps1`
2. Inspect `${CODEX_HOME:-$HOME/.codex}/pets/clippy` first. If no Clippy package exists, the user's install request authorizes the normal installer.
3. If the existing package is byte-identical, report that Clippy is already installed.
4. If a different Clippy package would be overwritten, ask for explicit approval before using `--force` or `-Force`.
5. Run the installer and report its verified target. The installer checks the bundled and installed SHA-256 hashes.
6. Tell the user to start a new Codex task or relaunch the desktop app if Clippy does not appear immediately.

Do not edit unrelated Codex settings, select a pet on the user's behalf, or write outside the exact `pets/clippy` package directory.

## Verify

Run the installer without `--force`; an identical installation exits successfully. Also confirm that `pet.json` contains `id: "clippy"`, `spriteVersionNumber: 2`, and `spritesheetPath: "spritesheet.webp"`.

## Uninstall

Only uninstall when the user explicitly requests removal. Use `../../scripts/uninstall_clippy_pet.sh --yes` on macOS/Linux or `../../scripts/uninstall-clippy-pet.ps1 -Yes` on Windows. The uninstallers remove only `pet.json` and `spritesheet.webp` from the exact Clippy directory and leave any unexpected files untouched.
