# MSR Recovery Slice v15.1 — Defiant Audit Schema Fix

## Purpose

Slice v15 exposed that the restored MSR database uses an older `lootdrop_entries`
schema. The first v15 audit referenced columns such as `minlevel`, `maxlevel`, and
`multiplier` on `lootdrop_entries`, but those columns are not present in this
baseline.

This slice replaces the Defiant spawn-source audit with a conservative read-only
version that avoids those newer columns and also prints the relevant table
schemas for review.

## Files

- `database/recovery/audits/19_defiant_spawn_source_audit.sql`
- `recovery/verify_recovery_slice_v15_1.py`

## Safety

Read-only only. This slice does not modify items, loot tables, merchants, NPCs,
or rules.

## Expected command sequence

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v15_1.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```
