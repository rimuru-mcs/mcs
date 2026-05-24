# EQEmu Modernization: A Thesis of Contributions

## Command-Line Build & Release
```powershell
# 1. Regenerate Projects (Localizes to /code/)
python generate_vcxproj.py

# 2. Complete Rebuild (Targets /server/bin/)
& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" code\EQEmu.sln /p:Configuration=Release /p:Platform=x64 /m:8 /verbosity:minimal
```

### Technical Summary
This document provides a comprehensive technical overview of the engineering milestones achieved to stabilize, restructure, and automate the EQEmu server release process. These contributions transformed a fragmented build environment into a standardized, portable, and "one-click" deployable system.

## 1. Core Build Stabilization
The initial phase focused on resolving deep-seated technical debt and compilation hurdles across the server's three primary tiers.

- **`common` Tier**: Resolved core architectural regressions and symbol inconsistencies. Fixed multiple `ObjectFileName` collisions in the project generator that were causing silent build failures.
- **`zone` Tier**: Eliminated legacy compiler crashes (C1001) by refining Link-Time Code Generation (LTCG) settings. Resolved signed/unsigned mismatch errors and bot command double-compilation bugs.
- **`hc` (Headless Client)**: Fixed undeclared global symbols (`LogSys`, `Log`, `path`) through precise macro restoration and link-time dependency mapping.

## 2. Structural Standardization (akk-stack)
To align with industry-standard deployment patterns, the repository was restructured from the ground up to follow the `akk-stack` layout.

- **Code/Data Segregation**: 
    - Moved all C++ build environment artifacts (solutions, projects, and intermediate "junk") into a dedicated `/code/` directory.
    - Dedicated the `/server/` root exclusively for production data (quests, maps, configs) and final release binaries.
- **Refined Release Pathing**: Redirected application outputs directly to `server/bin/`, while maintaining internal dependency libraries in `code/bin/` to prevent production clutter.
- **Filesystem Resolution**: Verified and refined the `PathManager` logic to ensure that binaries in `server/bin/` correctly resolve their relative data roots (`../eqemu_config.json`).

## 3. Integrated Release Automation
The project was elevated from a manual build process to an automated, "one-click" release engine.

- **Dynamic Project Generation**: Enhanced `generate_vcxproj.py` to handle structural redirection, automating the creation of the entire Visual Studio environment from a single command.
- **Runtime Dependency Collection**: Implemented automated Post-Build Events that dynamically collect and deploy all required runtime DLLs (`MariaDB`, `OpenSSL`, `Lua`, `Perl`) into the production folder.
- **Symbol Segregation**: Developed logic to automatically move debug symbols (`.pdb`) and export files into a segregated `build/` subdirectory, maintaining a clean production binary root.

## 4. Portability & Dependency Management
Ensured the server can be deployed on any modern Windows x64 environment without complex pre-installation.

- **Visual Studio Context (.vsconfig)**: Introduced a `.vsconfig` metadata layer. Opening the solution now automatically prompts Visual Studio to install missing `v143` toolsets and the required Windows SDK.
- **Integrated Asset Deployment**: Successfully integrated and validated over 1.3 GB of server assets (quests, maps, plugins), establishing a "ready-to-play" baseline directly from the repository.

## Conclusion
These contributions have transitioned the EQEmu server into a **modernized, portably-deployable asset**. The project now benefits from a clean, predictable developer experience and a production-congruent release structure that satisfies both Spire and akk-stack standards.
