#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "clippy-for-chatgpt"
PET = PLUGIN / "assets" / "pet" / "clippy"


def read_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def webp_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if len(data) < 30 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        raise ValueError("spritesheet is not a RIFF WebP file")
    offset = 12
    while offset + 8 <= len(data):
        chunk = data[offset : offset + 4]
        size = struct.unpack_from("<I", data, offset + 4)[0]
        payload = offset + 8
        if chunk == b"VP8X" and size >= 10:
            width = 1 + int.from_bytes(data[payload + 4 : payload + 7], "little")
            height = 1 + int.from_bytes(data[payload + 7 : payload + 10], "little")
            return width, height
        if chunk == b"VP8L" and size >= 5 and data[payload] == 0x2F:
            bits = int.from_bytes(data[payload + 1 : payload + 5], "little")
            width = 1 + (bits & 0x3FFF)
            height = 1 + ((bits >> 14) & 0x3FFF)
            return width, height
        if chunk == b"VP8 " and size >= 10 and data[payload + 3 : payload + 6] == b"\x9d\x01\x2a":
            width = int.from_bytes(data[payload + 6 : payload + 8], "little") & 0x3FFF
            height = int.from_bytes(data[payload + 8 : payload + 10], "little") & 0x3FFF
            return width, height
        offset = payload + size + (size % 2)
    raise ValueError("WebP has no readable VP8X, VP8L, or VP8 dimensions")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    plugin = read_json(PLUGIN / ".codex-plugin" / "plugin.json")
    marketplace = read_json(ROOT / ".agents" / "plugins" / "marketplace.json")
    pet = read_json(PET / "pet.json")
    artifact = read_json(PET / "artifact-manifest.json")

    require(plugin["name"] == "clippy-for-chatgpt", "plugin name mismatch")
    require(re.fullmatch(r"\d+\.\d+\.\d+", plugin["version"]) is not None, "plugin version is not strict semver")
    require(plugin.get("skills") == "./skills/", "skills path mismatch")
    require(marketplace["name"] == "clippy-for-chatgpt", "marketplace name mismatch")
    require(len(marketplace["plugins"]) == 1, "marketplace must contain exactly one plugin")
    require(marketplace["plugins"][0]["source"]["path"] == "./plugins/clippy-for-chatgpt", "marketplace source mismatch")
    require(pet["id"] == "clippy", "pet id mismatch")
    require(pet["spriteVersionNumber"] == 2, "spriteVersionNumber must be 2")
    require(pet["spritesheetPath"] == "spritesheet.webp", "spritesheetPath mismatch")
    require(webp_size(PET / "spritesheet.webp") == (1536, 2288), "spritesheet dimensions must be 1536x2288")

    for filename, metadata in artifact["files"].items():
        require(sha256(PET / filename) == metadata["sha256"], f"SHA-256 mismatch: {filename}")

    for path in (
        ROOT / "README.md",
        ROOT / "README.tr.md",
        ROOT / "PROMPTS.md",
        ROOT / "INSTALL-PROMPT-EN.txt",
        ROOT / "INSTALL-PROMPT-TR.txt",
        PLUGIN / "skills" / "install-clippy-pet" / "SKILL.md",
    ):
        require(path.is_file(), f"missing required file: {path.relative_to(ROOT)}")
        require("[TODO:" not in path.read_text(encoding="utf-8"), f"unfinished placeholder: {path.relative_to(ROOT)}")

    for path in (ROOT / "INSTALL-PROMPT-EN.txt", ROOT / "INSTALL-PROMPT-TR.txt"):
        prompt = path.read_text(encoding="utf-8")
        require("/v1.0.1/" in prompt, f"prompt is not pinned to v1.0.1: {path.name}")
        for filename, metadata in artifact["files"].items():
            require(filename in prompt, f"prompt does not name {filename}: {path.name}")
            require(metadata["sha256"] in prompt, f"prompt does not include {filename} SHA-256: {path.name}")

    print("OK: plugin, marketplace, pet dimensions, SHA-256 hashes, and standalone prompts are valid")


if __name__ == "__main__":
    main()
