# Recovery Slice v23 — Linux `ruletypes.h` macro compatibility

## Why this slice exists

The Ubuntu/GCC build fails in `common/ruletypes.h` because the `RULE_BOOL` macro requires four arguments:

```cpp
#define RULE_BOOL(cat, rule, default_value, notes)
```

but the custom rule block still contains an older three-argument rule:

```cpp
RULE_BOOL(Custom, IgnoreAALevelRequirements, false)
```

GCC correctly stops there, and the later `rulesys.h` errors are cascade failures from that one malformed rule macro.

## What this slice changes

The patcher updates the rule to include the required notes argument:

```cpp
RULE_BOOL(Custom, IgnoreAALevelRequirements, false, "Ignore AA level requirements for custom multiclass recovery behavior.")
```

This does not change the default value. It only makes the rule declaration compatible with the current four-argument rule macro.

## Apply

From the repo root:

```bash
python3 recovery/patch_ruletypes_linux_compat.py
python3 recovery/verify_recovery_slice_v23.py
```

Then rebuild:

```bash
rm -rf build/linux-release
cmake -S . -B build/linux-release \
  -DCMAKE_BUILD_TYPE=Release \
  -DEQEMU_BUILD_CLIENT_FILES=OFF \
  2>&1 | tee /opt/msr/logs/msr_linux_config_$(date +%Y%m%d_%H%M%S).log

cmake --build build/linux-release -j"$(nproc)" \
  2>&1 | tee /opt/msr/logs/msr_linux_build_$(date +%Y%m%d_%H%M%S).log
```

## Commit

```bash
git add common/ruletypes.h recovery/patch_ruletypes_linux_compat.py recovery/verify_recovery_slice_v23.py docs/recovery/RECOVERY_SLICE_V23_LINUX_RULETYPES_COMPAT.md
git commit -m "Build: fix MSR Linux rule macro compatibility"
```
