# Recovery Slice v25 — Linux Embperl Strings Include

## Purpose

The Linux build reached `zone/embperl.cpp` and failed because the file uses `Strings::Trim` and `Strings::Contains` without including `common/strings.h`.

MSVC tolerated this through transitive includes, but GCC does not. The fix is to add the direct include explicitly.

## Files

- `recovery/patch_embperl_strings_include.py`
- `recovery/verify_recovery_slice_v25.py`

## Apply

```bash
cd /opt/msr/repo/msr
python3 recovery/patch_embperl_strings_include.py
python3 recovery/verify_recovery_slice_v25.py
```

## Build

```bash
cmake --build build/linux-release -j"$(nproc)" \
  2>&1 | tee /opt/msr/logs/msr_linux_build_$(date +%Y%m%d_%H%M%S).log
```

## Notes

This is a portability fix only. It does not change Perl behavior or quest runtime behavior.
