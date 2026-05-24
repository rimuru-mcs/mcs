# Recovery Slice v24 — Linux popcount compatibility

## Purpose

The Linux build reached `zone/client.cpp` and failed in `Client::AddExtraClass` because the code used the MSVC intrinsic `__popcnt`.

`__popcnt` is available in the Visual Studio/MSVC build, but it is not portable to the GCC/Linux build path used by the MSR dev box.

## Change

`zone/client.cpp` now uses a local portable helper:

```cpp
int CountEnabledClassBits(uint32 classes_bits)
```

The helper uses Brian Kernighan's bit-count loop and avoids compiler-specific intrinsics.

## Scope

This slice only changes the multiclass class-bit counting implementation. It does not alter the multiclass cap logic or database writes.

## Expected result

Linux build should pass the previous `__popcnt` failure and continue further. If the build fails again, use the next Linux build log as the next recovery target.
