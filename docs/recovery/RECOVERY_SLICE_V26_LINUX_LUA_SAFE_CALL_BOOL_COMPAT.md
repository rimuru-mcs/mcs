# Recovery Slice v26 — Linux Lua Safe Call Bool Compatibility

## Purpose

The Linux build reached `zone/lua_client.cpp` and failed in `Lua_Client::AddExtraClass(int)` because the code called:

```cpp
Lua_Safe_Call_Bool(false);
```

This MSR codebase defines the macro as a zero-argument macro:

```cpp
#define Lua_Safe_Call_Bool() if(!d_) { return false; } NativeType *self = reinterpret_cast<NativeType*>(d_)
```

MSVC previously tolerated this path or did not expose it during the Windows build, but GCC correctly rejects the one-argument macro call.

## Change

Run:

```bash
python3 recovery/patch_lua_safe_call_bool_compat.py
```

This changes the call to:

```cpp
Lua_Safe_Call_Bool();
```

No behavior change is intended: the macro already returns `false` when the Lua wrapper has no native object, which matches the original attempted fallback.

## Verify

```bash
python3 recovery/verify_recovery_slice_v26.py
cmake --build build/linux-release -j"$(nproc)" 2>&1 | tee /opt/msr/logs/msr_linux_build_$(date +%Y%m%d_%H%M%S).log
```
