# MSR Gitignore Cleanup v2

This cleanup pass extends the first ignore rules to cover root-level extracted dependency/toolchain folders that appeared after the first VS2022 configure/build pass.

## Added coverage

- `/perl/` and `/perl*/` for extracted Strawberry Perl/runtime toolchains.
- `/vcpkg/` for local vcpkg exports/downloads.
- `*.included` for configured dependency marker/generated files.
- `/build_release_log.txt` and related local build logs.

These rules are root-scoped where practical so source libraries under `/libs` remain committable.

## Recommended Windows command

```powershell
powershell -ExecutionPolicy Bypass -File recovery\cleanup_generated_files_v2.ps1
```

The script runs `git reset`, verifies representative ignore rules with `git check-ignore`, removes ignored generated files with `git clean -fdX`, then prints a short Git status.
