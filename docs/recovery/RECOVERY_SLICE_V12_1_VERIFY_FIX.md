# MSR Recovery Slice v12.1 — Verify Fix

## Purpose

Slice v12 added the global buff runtime audit tooling, but the verifier was too strict: it required the source-audit script to contain its own filename as literal text.

The audit script existed and was valid, but the verifier failed before the runtime audit could be run.

## Files changed

- `recovery/audit_global_buff_runtime_code.py`
- `recovery/verify_recovery_slice_v12.py`

## Behavior

This slice keeps v12 read-only. It does not change database state, migrations, or runtime code.

It only makes the v12 verification pass and adds the script name to the generated audit text output for traceability.

## Verify

```bash
python3 recovery/verify_recovery_slice_v12.py
python3 recovery/audit_global_buff_runtime_code.py
```
