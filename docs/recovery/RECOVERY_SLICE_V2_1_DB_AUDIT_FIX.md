# MSR Recovery Slice v2.1 — DB Audit Script Fix and Findings

## Purpose

This slice fixes the Linux audit runner so it honors `MSR_DB_USER`, `MSR_DB_NAME`, and related environment variables instead of falling back to the MariaDB `root` user.

It also records the first restored-database audit findings from `msr_db_audit_20260524_075450.tar.gz` and corrects the pending Syncrosatchel price candidate so it uses EQEmu-style copper values rather than literal platinum values.

## Why this was needed

On Ubuntu/MariaDB, the database `root` account commonly uses unix-socket authentication. The previous audit script accidentally fell back to `root`, causing:

```text
ERROR 1698 (28000): Access denied for user 'root'@'localhost'
```

The `msr_audit` user itself was confirmed valid by direct MariaDB login.

## Apply

From the repository root:

```bash
bash recovery/run_db_audit.sh
```

Recommended environment:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password'

bash recovery/run_db_audit.sh
```

## First audit summary

The restored database is structurally present and usable. Key tables exist, including `rule_values`, `spells_new`, `items`, `merchantlist`, `npc_types`, `doors`, `zone`, and `zone_points`.

The first audit suggests the restored SQL dump is an older baseline, not the fully updated lost 5/23 state.

### High-confidence missing or incomplete items

- `Custom:PermanentServerBuffsEnabled` is missing before safe migration 010 is applied.
- Global buff spells `44000` through `44007` are not present in `spells_new` in the restored dump.
- `Echo of Power` is not present in the restored dump.
- Rule values still show tutorial entry enabled via `World:EnableTutorialButton = true`.
- `Spells:UseSpellImpliedTargeting` is still `false`.
- `Combat:MinRangedAttackDist` is still `25`.
- `Character:PerCharacterBucketMaxLevel` and `Character:PerCharacterQglobalMaxLevel` are still `false`.
- Syncrosatchel baseline exists, but expanded bag prices are still `500000000`, not the lost-note 5,000 platinum value.
- No 21-slot Transcendent Mage's Syncrosatchel row was confirmed by the audit.
- Audit found `104` sympathetic items still carrying level gates.
- Audit found `417` Defiant-named items still present in `items`.
- Merchant expansion gates still exist across many spell/item merchants.

## Next recommended recovery work

1. Apply only safe migrations 000 and 010 on the dev database.
2. Re-run the audit to confirm the recovery ledger and placeholder rule are present.
3. Promote reviewed rule defaults into a controlled safe migration only after confirming intended ruleset usage.
4. Reconstruct global buff spell rows from the 5/21 and 5/23 client spell files and compare them against server `spells_new` structure before adding them.
5. Compare source-code Syncrosatchel constants against audited item IDs before changing bag logic or DB IDs.
6. Do not run pending migrations blindly.
