# MSR Recovery Slice v3 — Safe DB Baseline Apply

## Purpose

Slice v3 makes the safe database migration runner usable for the MSR recovery lab.
It does **not** promote risky gameplay/data edits yet.

This slice is intentionally limited to:

- patching the safe migration runners so they default to the MSR recovery database/user instead of `root`/`peq`,
- refusing root migrations unless explicitly overridden,
- adding dry-run support,
- adding an audit that verifies the safe migration ledger and neutral rule placeholder.

## Why this exists

The restored database audit confirmed the DB is alive, but the backup is not the full lost 5/23 state.  It still lacks the permanent server buff toggle rule, the global buff spell rows, and several later rule/item/merchant changes.  Before applying real recovery fixes, the migration machinery must be boring, repeatable, and safe.

## Apply this slice

From the repo root:

```bash
python3 recovery/verify_recovery_slice_v3.py
```

Commit after verification:

```bash
git add .
git commit -m "Database: harden MSR safe migration runner"
```

## Apply safe migrations on the dev DB

Use the migration user, not root:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='your_migrate_password_here'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```

The safe migrations currently create/refresh:

- `msr_recovery_migration_log`
- disabled `Custom:PermanentServerBuffsEnabled` placeholder rule

They do not enable permanent buffs and do not modify items, doors, zones, loot, or merchants.

## Re-audit after applying

Switch back to the read-only audit user:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
```

The new `07_recovery_migration_log_audit.sql` output should show the ledger table, the applied safe migrations, and `Custom:PermanentServerBuffsEnabled=false`.

## What comes next

After Slice v3 is applied and audited, the next slice can promote the first truly low-risk DB behavior fixes, likely:

- implied targeting rule recovery,
- tutorial entry rule cleanup if supported by this schema,
- syncrosatchel price migration after merchant/item IDs are confirmed,
- sympathetic level-gate migration after spell IDs are confirmed.

Corpse-run, progression cap, zone-line, defiant loot removal, and global buff spell reconstruction should remain review-first until their exact effects are pinned down.
