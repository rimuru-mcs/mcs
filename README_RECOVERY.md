# NMS / Multiclass Server Recovery Notes

This repository snapshot is being recovered from the final archive left by the previous maintainer.

The current working assumption is that the `dinput8.pdb` and original `dinput8.dll` source project are unavailable. Because of that, the 5-23 client DLL is treated as quarantined until proven safe by client-side testing.

## Recovery Slice v1 status

This slice performs foundation work only:

- Fixes the default CMake configuration so missing `client_files/` no longer breaks configure.
- Wires the new `common/process/process_helper.*` files into `common/CMakeLists.txt`.
- Replaces the split/orphaned `Process` helper state with one canonical declaration/implementation.
- Fixes `generate_vcxproj.py` so generated solution/project GUIDs are valid.
- Makes the Visual Studio generator skip missing project directories instead of generating empty broken projects.
- Adds client patch baselines:
  - `client_patches/stable_5_21_base/`
  - `client_patches/test_5_21_dll_5_23_spells_storyline/`
  - `client_patches/quarantine_5_23_reported_crash/`
- Adds a manifest containing file sizes and SHA-256 hashes for the client patch layouts.

## Client DLL policy

Use this policy until the original client DLL source/PDB is recovered:

1. Treat the 5-21 `dinput8.dll` as the safe baseline.
2. Treat the 5-23 `dinput8.dll` as quarantined.
3. Test 5-23 spell/storyline data with the 5-21 DLL before testing the 5-23 DLL.
4. Do not ship the 5-23 DLL to players until it passes a focused client test matrix.

## Suggested client test matrix

| Test | DLL | Spells/storyline | Purpose |
|---|---|---|---|
| A | 5-21 | 5-21 | Known-safe fallback candidate |
| B | 5-21 | 5-23 | Tests whether 5-23 data is safe without new hooks |
| C | 5-23 | 5-21 | Tests whether 5-23 DLL crashes by itself |
| D | 5-23 | 5-23 | Reproduces reported crash package |

## Notes

This slice does not attempt to rebuild the missing 5-20, 5-21, or 5-23 gameplay/database fixes yet. Those should be recovered after the repository can build cleanly and the client baseline is stable.
