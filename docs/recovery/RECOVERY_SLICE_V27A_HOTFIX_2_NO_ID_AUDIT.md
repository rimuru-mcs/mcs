# MSR v27a hotfix 2 — no-id migration and audit fix

This bundle replaces the v27a Crescent Reach migration, audit, and verifier.

## Fixes

- `database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql`
  - avoids `b.id` / `sz.id`
  - keeps compatibility marker text for the v27a verifier
  - remains idempotent

- `database/recovery/audits/27_crescent_start_and_zone_entry_audit.sql`
  - no longer selects `start_zones.id`
  - no longer orders by `start_zones.id`
  - works with the recovered no-id `start_zones` schema

- `recovery/verify_recovery_slice_v27a.py`
  - checks for the no-id-safe audit and migration
  - rejects the old `b.id` and `ORDER BY ... id` failure patterns

## Apply

Extract over the repo root, then run:

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v27a.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='msrtest'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh

export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'
bash recovery/run_db_audit.sh
```
