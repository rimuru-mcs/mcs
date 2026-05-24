# MSR Recovery Slice v2 — Database Baseline and Migration Scaffold

## Purpose

Recovery Slice v1 made the source tree buildable again. Slice v2 adds the database recovery structure needed before we start rewriting gameplay fixes from the lost 5/20, 5/21, and 5/23 updates.

This slice is deliberately audit-first. It does **not** blindly apply the changelog as SQL. The uploaded SQL backup appears to be a full baseline dump rather than a later delta, so the safe path is:

1. audit the live/restored database,
2. record what already exists,
3. apply only neutral schema/tooling changes,
4. stage risky gameplay SQL as pending until it has been reviewed against the live data.

## Added layout

```text
/database/recovery/
  README.md
  RECOVERY_DB_FIX_MAP.md
  audits/
    00_schema_presence.sql
    01_rules_and_server_defaults_audit.sql
    02_global_buffs_audit.sql
    03_syncrosatchel_audit.sql
    04_sympathetic_items_audit.sql
    05_zone_access_waypoints_audit.sql
    06_defiant_and_missing_items_audit.sql
  migrations_safe/
    000_create_msr_recovery_ledger.sql
    010_add_neutral_recovery_rule_placeholders.sql
  migrations_pending/
    020_review_rules_recovery_candidates.sql
    030_review_global_buff_candidates.sql
    040_review_zone_waypoint_candidates.sql
    050_review_syncrosatchel_candidates.sql
    060_review_sympathetic_item_candidates.sql
/recovery/
  run_db_audit.ps1
  run_db_audit.sh
  apply_db_migrations.ps1
  apply_db_migrations.sh
  verify_recovery_slice_v2.py
```

## Safe migrations

The `migrations_safe` folder contains only tooling/neutral inserts:

- `msr_recovery_migration_log` ledger table
- `Custom:PermanentServerBuffsEnabled` rule placeholder set to `false`

The permanent-server-buff rule is intentionally inserted as `false`. That records the rule name without enabling behavior before the matching code and spell/database rows are verified.

## Pending migrations

The `migrations_pending` folder contains reviewable SQL candidate files. They are not run by the apply scripts.

They cover the recovery areas from the lost update notes:

- corpse-run/tutorial/implied-healing/ranged-distance/max-level rule candidates
- global buff spell IDs 44000–44007 and Echo of Power consolidation
- Nektulos, Lavastorm, Crescent Reach, Rathe Mountains, starter-city waypoint, and Classic Planes audit points
- syncrosatchel item/merchant checks
- sympathetic proc level checks and Simple Ring of the Hero verification

## Windows usage

From repo root:

```powershell
py -3 recovery\verify_recovery_slice_v2.py
```

Run audits against a local database:

```powershell
$env:MSR_DB_PASSWORD = "your-password"
powershell -ExecutionPolicy Bypass -File recovery\run_db_audit.ps1 -Database peq -User root
```

Apply safe migrations only:

```powershell
$env:MSR_DB_PASSWORD = "your-password"
powershell -ExecutionPolicy Bypass -File recovery\apply_db_migrations.ps1 -Database peq -User root
```

If no password environment variable is set, the MariaDB/MySQL client will prompt.

## Linux/Git Bash usage

```bash
python3 recovery/verify_recovery_slice_v2.py
MSR_DB_PASSWORD='your-password' bash recovery/run_db_audit.sh --database peq --user root
MSR_DB_PASSWORD='your-password' bash recovery/apply_db_migrations.sh --database peq --user root
```

## Commit name

Recommended commit:

```text
Database: add MSR recovery audit and migration scaffold
```
