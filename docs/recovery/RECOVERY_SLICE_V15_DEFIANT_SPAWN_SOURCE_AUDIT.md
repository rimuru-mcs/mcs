# MSR Recovery Slice v15 — Defiant Spawn Source Audit

## Purpose

The recovered update notes say Defiant gear was fixed so it no longer spawned in game. The restored database still contains Defiant-named item rows, which is not automatically a bug by itself. The dangerous part is whether those item IDs are still referenced by loot tables, merchants, or other spawn/source tables.

This slice is read-only. It adds a focused audit that maps Defiant item rows to likely world-entry sources.

## Added files

- `database/recovery/audits/19_defiant_spawn_source_audit.sql`
- `database/recovery/migrations_pending/130_review_defiant_spawn_cleanup.sql`
- `docs/recovery/RECOVERY_SLICE_V15_DEFIANT_SPAWN_SOURCE_AUDIT.md`
- `recovery/verify_recovery_slice_v15.py`

## Safety posture

Do not delete Defiant item rows yet. Item rows may be required for client compatibility, historical references, GM tools, or future comparison. The safer first fix is to remove or disable sources that place those items into normal gameplay.

## Expected next step

Run the audit and package `database/recovery/audit_output`. If Defiant rows exist in `lootdrop_entries` or `merchantlist`, the next slice can promote a targeted cleanup migration.
