# MSR Recovery Slice v17 — Blackburrow Door Recovery

## Purpose

Recover the lost update note:

> Fixed Doors in Blackburrow where set to jaggedpines rather than open door making it so you couldnt open doors due to progression lockout.

## Audit finding before v17

Earlier zone/door audits showed Blackburrow version 0 door rows with:

- `zone = blackburrow`
- `version = 0`
- `dest_zone = jaggedpine`

That made normal doors behave like zone teleports to Jaggedpine, which could trigger progression lockout behavior instead of opening the door.

## Recovery decision

Do **not** delete doors.

Instead:

- back up affected rows into `msr_recovery_blackburrow_door_backup`
- clear the accidental teleport target
- set `dest_zone = 'NONE'`
- set destination coordinates to `0`

Only Blackburrow version 0 doors targeting Jaggedpine are touched.

## Files added

- `database/recovery/migrations_safe/090_fix_blackburrow_jaggedpine_door_targets.sql`
- `database/recovery/audits/21_blackburrow_door_recovery_audit.sql`
- `database/recovery/migrations_pending/140_review_blackburrow_door_recovery.sql`
- `recovery/verify_recovery_slice_v17.py`

## Apply

```bash
cd /opt/msr/repo/msr

python3 recovery/verify_recovery_slice_v17.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='msrtest'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```

## Verify

```bash
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```

Expected audit outcome:

- `blackburrow_doors_still_targeting_jaggedpine = 0`
- `blackburrow_door_backup_summary.backup_rows` equals the number of affected rows from before the migration
