# MSR Recovery Slice v7 — Bucket Progression Cap Recovery

## Purpose

Slice v7 promotes the progression max-level recovery after Slice v6 audit output confirmed that this restored MSR database stores per-character `CharMaxLevel` values in `data_buckets`, not `quest_globals`.

The lost 5/21 notes mention that players could level past their progression cap. The source code supports two possible cap sources:

```text
Character:PerCharacterQglobalMaxLevel  -> quest_globals name='CharMaxLevel'
Character:PerCharacterBucketMaxLevel   -> data_buckets key='CharMaxLevel'
```

The code checks qglobal first. Since the audit found bucket rows and no qglobal rows, Slice v7 enables only the bucket-backed path.

## Added files

```text
database/recovery/migrations_safe/050_apply_bucket_progression_cap_recovery.sql
database/recovery/audits/11_progression_cap_recovery_audit.sql
recovery/verify_recovery_slice_v7.py
docs/recovery/RECOVERY_SLICE_V7_BUCKET_PROGRESSION_CAP.md
```

## Updated files

```text
database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql
database/recovery/migrations_pending/070_review_progression_cap_candidates.sql
```

## Migration behavior

The safe migration sets this across all existing rule sets:

```text
Character:PerCharacterBucketMaxLevel  = true
Character:PerCharacterQglobalMaxLevel = false
```

It intentionally does **not** change:

```text
Character:MaxLevel
Character:MaxExpLevel
Character:KeepLevelOverMax
existing character levels
```

## Important audit note

The Slice v6 audit showed two development characters already above the recovered bucket cap. Slice v7 does not manually delevel characters. It enables server-side cap enforcement so new XP flow should respect the `CharMaxLevel` bucket path.

## Apply on the MSR dev repo

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v7.py

git add .
git commit -m "Database: enable bucket-backed MSR progression caps"
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
