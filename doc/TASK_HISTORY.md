# EQEmu Modernization Task History

- [x] Initial Build Fixes
    - [x] Resolve `common` project build errors
    - [x] Fix `ObjectFileName` collisions in `generate_vcxproj.py`
    - [x] Configure `zlib-ng` and `fmt` libraries correctly
- [x] Resolve `zone` project residuals
    - [x] Fix `process.h` include in `embperl.cpp`
    - [x] Fix unary minus on unsigned in `spell_effects.cpp`
    - [x] Fix bot command double compilation
    - [x] Fix `worldserver.cpp` uninitialized pointer
    - [x] Resolve compiler crash (LTCG SUCCESS)
- [x] Resolve `hc` (Headless Client) errors
    - [x] Fix `LogSys` and `path` undeclared symbols
    - [x] Fix missing `Log` global symbol
    - [x] Verify final linking (PASSED)
- [x] Standardize Release Portability
    - [x] Automate DLL copying in `generate_vcxproj.py`
    - [x] Verify inclusion of all required runtime dependencies
- [x] Final Build Verification
    - [x] Perform full Release x64 rebuild
    - [x] Verify generated binaries in `build/bin/Release`
    - [x] Smoke test `world.exe` (PASSED)
    - [x] Smoke test `zone.exe` (PASSED)
- [x] akk-stack Structural Refinement
    - [x] Create `/code/` build directory
    - [x] Update `generate_vcxproj.py` for `/code/` and `/server/bin/` redirection
    - [x] Perform deep cleanup (logs, legacy directories)
    - [x] Automate Platform Toolset retrieval via `.vsconfig`
    - [x] Final distribution verification in `/server/bin/`

## Standardized Layout (akk-stack)
| Component | Folder | Purpose |
| :--- | :--- | :--- |
| **Build Environment** | `/code/` | Visual Studio solutions, projects, and intermediate `obj/` |
| **Production Data** | `/server/` | Quests, Maps, Scripts, and Configs |
| **Final Release** | `/server/bin/` | Optimized binaries, required runtime DLLs |
| **Debug Symbols** | `/server/bin/build/` | PDB files and linker exports |
