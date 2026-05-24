# MSR Recovery Slice v8 — Sympathetic Item Level Gate Recovery

## Purpose

Slice v8 promotes the low-risk database half of the lost 5/23 Sympathetic item fix.

The lost notes say Sympathetic items were fixed so they proc at all levels instead of being blocked by level gates. The restored database audit still showed Sympathetic item effect rows with non-zero proc/worn/focus level gates.

## Added files

```text
database/recovery/migrations_safe/060_apply_sympathetic_level_gate_recovery.sql
database/recovery/audits/12_sympathetic_level_gate_recovery_audit.sql
recovery/verify_recovery_slice_v8.py
docs/recovery/RECOVERY_SLICE_V8_SYMPATHETIC_LEVEL_GATE.md
```

## Updated files

```text
database/recovery/migrations_pending/060_review_sympathetic_item_candidates.sql
```

## Migration behavior

The safe migration:

- Finds spell IDs in `spells_new` whose names contain `Sympathetic`.
- Finds `items` rows where `proceffect`, `worneffect`, or `focuseffect` points to those spells.
- Sets the matching effect level gates to `0`:
  - `proclevel`, `proclevel2`
  - `wornlevel`, `wornlevel2`
  - `focuslevel`, `focuslevel2`

It intentionally does **not** change:

```text
reqlevel
reclevel
classes
slots
prices
effect IDs
Simple Ring of the Hero
```

## Why Simple Ring is not patched here

The lost notes also mention adding `Sympathetic Strike I` to `Simple Ring of the Hero`, but the restored audit did not yet prove the exact intended item row and effect pairing. That should be handled in a separate targeted slice after audit truth confirms the item and spell IDs.

## Apply on the MSR dev repo

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v8.py

git add .
git commit -m "Database: remove MSR Sympathetic item level gates"
```

## Apply safe migrations

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='your_migrate_password_here'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```

## Re-run audit

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```
