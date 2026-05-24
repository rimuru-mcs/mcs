#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# These were orphaned by the recovered working tree and conflict conceptually with
# common/process/process_helper.*. They are not referenced after this slice.
rm -f common/eqemu_process.cpp common/eqemu_process.h

# Remove stale generated project files so generate_vcxproj.py can recreate them cleanly.
rm -rf code

python3 -m py_compile generate_vcxproj.py
python3 generate_vcxproj.py

cmake -S . -B build/recovery-v1-configure-check \
  -DEQEMU_BUILD_SERVER=OFF \
  -DEQEMU_BUILD_LOGIN=OFF \
  -DEQEMU_BUILD_HC=OFF \
  -DEQEMU_BUILD_TESTS=OFF \
  -DEQEMU_BUILD_CLIENT_FILES=OFF

echo "Recovery Slice v1 applied and lightweight configure check completed."
