$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RepoRoot

# These were orphaned by the recovered working tree and conflict conceptually with
# common/process/process_helper.*. They are not referenced after this slice.
Remove-Item -Force -ErrorAction SilentlyContinue common\eqemu_process.cpp, common\eqemu_process.h

# Remove stale generated project files so generate_vcxproj.py can recreate them cleanly.
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue code

python -m py_compile generate_vcxproj.py
python generate_vcxproj.py

cmake -S . -B build\recovery-v1-configure-check `
  -DEQEMU_BUILD_SERVER=OFF `
  -DEQEMU_BUILD_LOGIN=OFF `
  -DEQEMU_BUILD_HC=OFF `
  -DEQEMU_BUILD_TESTS=OFF `
  -DEQEMU_BUILD_CLIENT_FILES=OFF

Write-Host "Recovery Slice v1 applied and lightweight configure check completed."
