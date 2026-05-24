# MSR Gitignore Cleanup v1

This cleanup slice prevents generated Visual Studio/CMake build output from being committed.

## Why this exists

The first successful VS2022 build created thousands of generated files under `build/vs2022`, including precompiled headers larger than GitHub's 100 MB file limit. Those files should never be committed.

## What is ignored

- Root build directories such as `build/`, `build*/`, and `cmake-build-*`.
- Generated Visual Studio/CMake files.
- MSVC intermediate files such as `.obj`, `.pch`, `.idb`, and `.ilk`.
- Python caches such as `__pycache__/` and `.pyc` files.
- Local dependency/download caches.
- Local runtime config and environment files.
- Logs, dumps, and temporary files.

## What is intentionally not globally ignored

The file does not globally ignore `.dll`, `.exe`, `.lib`, `.zip`, or `.rar` because this recovery project may intentionally track small client patch artifacts or database/recovery archives. Large generated package names should be ignored by specific pattern instead.

## Recommended cleanup command

From the repository root on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File recovery\cleanup_generated_files.ps1
```

This runs:

```powershell
git reset
git clean -fdX -n
git clean -fdX
git status --short
```

`git clean -fdX` only removes ignored files. It does not remove ordinary untracked source files.
