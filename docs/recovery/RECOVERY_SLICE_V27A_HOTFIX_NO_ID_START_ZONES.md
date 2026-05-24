# MSR v27a hotfix — Crescent start-zone migration no-id fix

This bundle replaces:

`database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql`

The previous v27a migration assumed `start_zones` had an `id` column. This recovered MSR schema does not, so the migration failed at:

`Unknown column 'b.id' in 'WHERE'`

This fixed migration uses a natural-key backup match across the start-zone selector and location fields instead.

Apply by extracting over the repo root, then rerun:

```bash
python3 recovery/verify_recovery_slice_v27a.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='msrtest'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```
