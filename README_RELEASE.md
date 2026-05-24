# EQEmu akk-stack Refined Release Walkthrough

The repository is now structured according to **akk-stack standards**, segregating developer build artifacts from production server data and binaries.

## Standardized Structure

Building the solution is now localized within the `/code/` directory, while the "ready-to-play" package is automatically maintained in `/server/`.

```text
/
├── code/                      # C++ Build Environment
│   ├── EQEmu.sln
│   ├── obj/                   # Compilation intermediate files
│   └── bin/                   # Build-time Static Libraries
├── server/                    # Production Data (Non-binary)
│   ├── bin/                   # Final Binaries (.exe) and Runtime DLLs
│   │   └── build/             # Production Symbols (.pdb) and Exports
│   ├── quests/                # Scripting and quest files
│   ├── Maps/                  # Navmesh and map files
│   ├── eqemu_config.json      # Server configuration
│   └── spire.exe              # Server launcher
└── generate_vcxproj.py        # Integrated project generator
```

## Refinement Highlights

### 1. akk-stack Structural Redirection
`generate_vcxproj.py` was updated to align with the refined layout:
- **Build Environment**: All Visual Studio solution and project files are generated in the `/code/` directory.
- **Diverted Outputs**: 
    - **World/Zone/App** binaries are diverted directly to `server/bin/`.
    - **Library** binaries are kept within `code/bin/` to keep the production root clean.
- **Intermediate "Junk"**: All compilation temporary files are consolidated in `code/obj/`.

### 2. Automated DLL & Symbol Management
Required `vcpkg` and `perl` DLLs are automatically copied to `server/bin/` upon build completion. Additionally, build symbols (`.pdb`) are segregated into a `build/` subdirectory to maintain a clean, production-congruent binary folder.

### 4. Automatic Toolset Retrieval
A `.vsconfig` file has been added to the root. Opening the solution in Visual Studio will now automatically prompt you to install any missing dependencies, such as the `v143` toolset and the required Windows SDK.

## Workflow: How to Build & Release
1.  **Regenerate**: If new projects are added, run `python generate_vcxproj.py`.
2.  **Compile**: Open `code/EQEmu.sln` in Visual Studio.
3.  **Target**: Set configuration to **Release / x64** and **Build Solution**.
4.  **Play**: Your production-ready server resides in the `server/` directory.

> [!NOTE]
> Smoke tests confirm that `world.exe` launched from `server/bin/` correctly resolves the root `../eqemu_config.json` and initializes the server environment as expected.
