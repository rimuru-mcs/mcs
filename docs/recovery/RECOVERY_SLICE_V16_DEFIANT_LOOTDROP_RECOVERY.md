# MSR Recovery Slice v16 — Defiant Lootdrop Spawn Recovery

## Purpose

Recover the lost update note:

> Fixed an issue that was allowing defiant gear to spawn in game

The v15/v15.1 audits showed the restored DB still contains Defiant item rows, but the actual spawn path is lootdrop-based.

## Audit findings before v16

- Defiant item rows: 417
- Defiant active lootdrop rows: 372
- Defiant loottable links: 372
- Defiant NPC direct source rows: 0
- Defiant merchant rows: 0

## Recovery decision

Do **not** delete Defiant items.

Instead, disable active Defiant lootdrop source rows:

- preserve `items`
- preserve `lootdrop_entries`
- preserve `loottable_entries`
- preserve original active `chance` in `disabled_chance` when `disabled_chance = 0`
- set active `chance = 0`

This matches the recovery goal of preventing Defiant gear from spawning while keeping the data reversible for dev analysis.

## Files added

- `database/recovery/migrations_safe/080_disable_defiant_lootdrop_spawn_sources.sql`
- `database/recovery/audits/20_defiant_spawn_cleanup_recovery_audit.sql`
- `database/recovery/migrations_pending/130_review_defiant_spawn_cleanup.sql`
- `recovery/verify_recovery_slice_v16.py`

## Apply

```bash
cd /opt/msr/repo/msr

python3 recovery/verify_recovery_slice_v16.py

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

- `defiant_lootdrop_rows_still_active = 0`
- `defiant_lootdrop_rows_disabled = 372` or the matching number from the pre-v16 audit
- merchant rows remain `0`
