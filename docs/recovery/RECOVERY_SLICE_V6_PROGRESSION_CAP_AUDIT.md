# MSR Recovery Slice v6 — Progression Cap Audit

## Purpose

Slice v6 does **not** apply progression-cap changes yet. It adds a focused audit so we can determine whether the recovered database stores `CharMaxLevel` progression caps in `data_buckets` or `quest_globals` before enabling the server-side enforcement rule.

The lost 5/21 notes say players could level past their progression max. The source code supports this recovery, but the two storage modes are mutually important:

```text
Character:PerCharacterQglobalMaxLevel  -> quest_globals name='CharMaxLevel'
Character:PerCharacterBucketMaxLevel   -> data_buckets key='CharMaxLevel'
```

The server checks qglobal first. If both rules are enabled and caps actually live in `data_buckets`, the bucket caps can be ignored. Ciel refuses to let that goblin into production.

## Added files

```text
database/recovery/audits/10_progression_cap_storage_audit.sql
database/recovery/migrations_pending/070_review_progression_cap_candidates.sql
recovery/verify_recovery_slice_v6.py
docs/recovery/RECOVERY_SLICE_V6_PROGRESSION_CAP_AUDIT.md
```

## Updated files

```text
database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql
```

## What the audit checks

```text
rule_values progression/max-level settings
character_data level distribution
CharMaxLevel rows in data_buckets
CharMaxLevel rows in quest_globals
characters currently above their stored cap
cap value distribution by storage source
```

## Apply on the MSR dev repo

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v6.py

git add .
git commit -m "Database: audit MSR progression cap storage"
```

## Run audit

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

Send the audit bundle back before any progression-cap migration is promoted.

## Still pending after this slice

```text
Progression cap enforcement migration
Global buff spell rows and Custom:PermanentServerBuffsEnabled enablement
Defiant loot/spawn cleanup
Sympathetic proc level gates
21-slot Transcendent Mage's Syncrosatchel exact restore
Zone/version/waypoint repairs
```
