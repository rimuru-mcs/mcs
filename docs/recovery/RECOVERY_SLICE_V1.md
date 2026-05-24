# Recovery Slice v1: Build Stabilization and Client Quarantine

## Purpose

Stabilize the recovered Multiclass Server repository enough to begin safe bug-fix recovery work.

## Server-side changes

### Root CMake

`EQEMU_BUILD_CLIENT_FILES` now defaults to `OFF` because the recovered working tree has deleted `client_files/`.

If someone explicitly enables `EQEMU_BUILD_CLIENT_FILES`, CMake now checks whether `client_files/CMakeLists.txt` exists. If it is missing, CMake emits a warning and skips the client file utilities instead of failing configure immediately.

### Common process helper

The recovered working tree had deleted legacy files:

- `common/process.cpp`
- `common/process.h`
- `common/process/process.cpp`
- `common/process/process.h`

It also had two new competing process helper implementations:

- `common/process/process_helper.*`
- `common/eqemu_process.*`

This slice makes `common/process/process_helper.*` the canonical implementation and updates `common/CMakeLists.txt` accordingly.

### Visual Studio generator

`generate_vcxproj.py` now:

- validates and normalizes GUIDs;
- uses valid category GUIDs;
- avoids double-wrapping project GUIDs in braces;
- skips missing project directories such as `client_files/export` and `client_files/import`;
- uses only active projects when generating solution configuration and dependency sections.

## Client-side changes

The client patch files are staged under `client_patches/`.

### Safe baseline

`client_patches/stable_5_21_base/`

Uses the 5-21 DLL and 5-21 spell files.

### Diagnostic test package

`client_patches/test_5_21_dll_5_23_spells_storyline/`

Uses the 5-21 DLL with the 5-23 spell files and storyline files.

This package is meant to answer: "Do the 5-23 data files behave without the 5-23 DLL?"

### Quarantine package

`client_patches/quarantine_5_23_reported_crash/`

Contains the full 5-23 patch, including the reported-crash DLL.

Do not ship this to players as a stable patch.

## Verification performed in this environment

- `python3 -m py_compile generate_vcxproj.py` succeeded.
- `python3 generate_vcxproj.py` succeeded.
- Generated `code/EQEmu.sln` no longer contains double-braced project GUIDs.
- Generated `code/EQEmu.sln` does not include missing `export_client_files` or `import_client_files` projects.
- Lightweight CMake configure succeeded with all major app targets disabled and `EQEMU_BUILD_CLIENT_FILES=OFF`.

## Verification not performed here

- Full Windows/MSVC build was not performed in this Linux sandbox.
- Full server build with all dependencies was not completed here.
- Live EQ client testing was not performed here.
