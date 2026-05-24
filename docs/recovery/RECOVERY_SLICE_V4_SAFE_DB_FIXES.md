# MSR Recovery Slice v4 — Safe DB Fixes

## Purpose

Slice v4 promotes the first non-neutral database fixes from the lost 5/20–5/21 notes, but only where the restored audit output gave enough confidence to make the change safely.

This slice intentionally avoids global buffs, corpse/death rules, Defiant cleanup, sympathetic proc changes, and zone/waypoint rewrites. Those are still real recovery targets, but they need separate validation.

## Added files

```text
database/recovery/migrations_safe/020_apply_safe_rule_recovery_defaults.sql
database/recovery/migrations_safe/030_apply_syncrosatchel_price_recovery.sql
database/recovery/audits/08_safe_rule_and_syncrosatchel_recovery_audit.sql
recovery/verify_recovery_slice_v4.py
docs/recovery/RECOVERY_SLICE_V4_SAFE_DB_FIXES.md
```

## Updated files

```text
database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql
database/recovery/migrations_pending/050_review_syncrosatchel_candidates.sql
```

## Safe changes promoted

### Rules

```text
World:EnableTutorialButton          false
Spells:UseSpellImpliedTargeting    true
Combat:MinRangedAttackDist         0
```

### Syncrosatchel pricing

```text
Expanded %Syncrosatchel% item rows -> price 5,000,000 copper / 5,000 platinum
```

## Still pending

```text
Corpse-run/death rules
Per-character progression max-level enforcement
Global buff spell rows and Custom:PermanentServerBuffsEnabled enablement
Defiant loot/spawn cleanup
Sympathetic proc level gates
21-slot Transcendent Mage's Syncrosatchel exact restore
Zone/version/waypoint repairs
```

## Apply on the MSR dev DB

Use the migration user:

```bash
cd /opt/msr/repo/msr

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='your_migrate_password_here'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```

Then re-run audits with the audit user:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
```

Package the audit output:

```bash
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```

## Commit message

```text
Database: apply safe MSR rule and Syncrosatchel recovery fixes
```
