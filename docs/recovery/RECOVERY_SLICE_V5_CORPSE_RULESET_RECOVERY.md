# MSR Recovery Slice v5 — Corpse-Run and Ruleset Coverage Recovery

## Purpose

Slice v5 promotes the next low-risk DB recovery fix from the lost notes: preventing corpse runs. It also fixes a ruleset coverage gap discovered in the Slice v4 audit.

The Slice v4 audit showed `Combat:MinRangedAttackDist = 0` in ruleset 1 but `Combat:MinRangedAttackDist = 25` still present in ruleset 10. Since EQEmu loads default rules and then active overrides, existing override rows can undo safe recovery fixes. Slice v5 updates existing override rows for the safe rules already promoted.

## Added files

```text
database/recovery/migrations_safe/040_apply_corpse_run_and_ruleset_coverage_recovery.sql
database/recovery/audits/09_corpse_and_ruleset_coverage_audit.sql
recovery/verify_recovery_slice_v5.py
docs/recovery/RECOVERY_SLICE_V5_CORPSE_RULESET_RECOVERY.md
```

## Updated files

```text
database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql
```

## Safe changes promoted

### Corpse-run prevention

```text
Character:LeaveCorpses        false
Character:LeaveNakedCorpses   true
Character:DeathItemLossLevel  255
```

This is intended to preserve naked corpses for resurrection flow while preventing inventory/cash corpse runs.

### Ruleset override coverage

Existing override rows are also normalized for:

```text
Combat:MinRangedAttackDist       0
World:EnableTutorialButton       false
Spells:UseSpellImpliedTargeting  true
```

## Still pending

```text
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
Database: prevent MSR corpse runs and cover ruleset overrides
```
