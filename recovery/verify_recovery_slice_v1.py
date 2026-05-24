#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "CMakeLists.txt",
    "common/CMakeLists.txt",
    "common/process/process_helper.cpp",
    "common/process/process_helper.h",
    "generate_vcxproj.py",
    "client_patches/client_patch_manifest.json",
    "README_RECOVERY.md",
    "docs/recovery/RECOVERY_SLICE_V1.md",
]

BAD_CMAKE_REFS = [
    "process/process.cpp",
    "process.cpp",
    "process/process.h",
    "process.h",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    errors: list[str] = []

    for rel in REQUIRED:
        if not (ROOT / rel).exists():
            errors.append(f"missing required file: {rel}")

    common_cmake = (ROOT / "common/CMakeLists.txt").read_text(errors="replace")
    for ref in BAD_CMAKE_REFS:
        if ref in common_cmake:
            errors.append(f"common/CMakeLists.txt still references deleted legacy process file: {ref}")

    root_cmake = (ROOT / "CMakeLists.txt").read_text(errors="replace")
    if 'OPTION(EQEMU_BUILD_CLIENT_FILES "Build Client Import/Export Data Programs." OFF)' not in root_cmake:
        errors.append("EQEMU_BUILD_CLIENT_FILES does not default to OFF")
    if "client_files/CMakeLists.txt" not in root_cmake:
        errors.append("root CMake does not guard missing client_files/CMakeLists.txt")

    manifest_path = ROOT / "client_patches/client_patch_manifest.json"
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text())
        stable = manifest.get("stable_5_21_base", [])
        quarantine = manifest.get("quarantine_5_23_reported_crash", [])
        stable_dll = next((f for f in stable if f["path"].endswith("dinput8.dll")), None)
        quarantine_dll = next((f for f in quarantine if f["path"].endswith("dinput8.dll")), None)
        if not stable_dll:
            errors.append("stable client patch is missing dinput8.dll")
        if not quarantine_dll:
            errors.append("quarantine client patch is missing dinput8.dll")
        if stable_dll and quarantine_dll and stable_dll["sha256"] == quarantine_dll["sha256"]:
            errors.append("stable and quarantined dinput8.dll hashes unexpectedly match")

    try:
        subprocess.run([sys.executable, "-m", "py_compile", "generate_vcxproj.py"], cwd=ROOT, check=True)
    except subprocess.CalledProcessError as exc:
        errors.append(f"generate_vcxproj.py failed py_compile: {exc}")

    sln = ROOT / "code/EQEmu.sln"
    if sln.exists():
        text = sln.read_text(encoding="utf-8-sig", errors="replace")
        if "{{" in text or "}}" in text:
            errors.append("generated solution contains double-braced GUIDs")
        if "export_client_files" in text or "import_client_files" in text:
            errors.append("generated solution still includes missing client_files projects")
        for guid in re.findall(r"\{([^{}]+)\}", text):
            if len(guid) == 36:
                try:
                    import uuid
                    uuid.UUID(guid)
                except ValueError:
                    errors.append(f"invalid GUID in solution: {guid}")

    if errors:
        print("Recovery Slice v1 verification FAILED:")
        for error in errors:
            print(f" - {error}")
        return 1

    print("Recovery Slice v1 verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
