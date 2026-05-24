# MSR Recovery Slice v11 — Global Buff Spell Row Recovery

## Purpose

Slice v11 reconstructs the missing global/server buff rows in `spells_new` using the recovered 5/23 client `spells_us.txt` truth extracted during Slice v10.

The recovered rows are:

| ID | Name |
|---:|---|
| 44000 | Echo of Experience |
| 44001 | Echo of Power |
| 44002 | Echo of Statistics |
| 44003 | Echo of Speed |
| 44004 | Echo of Mana |
| 44005 | Echo of Haste |
| 44006 | Echo of Health |
| 44007 | Echo of Luck |

## Safety posture

This slice **does not enable permanent server buffs**.

`Custom:PermanentServerBuffsEnabled` remains `false` after this migration. The goal is only to restore the spell-row data that the server/client now expect to exist.

## Why 5/23 rows

Slice v10 extracted 80 matching rows across repo-staged client patch copies and the uploaded patch ZIPs. The 5/23 patch rows were selected because they represent the latest documented update, including the 5/23 change that consolidated power buffs into `Echo of Power`.

## Files added

- `database/recovery/migrations_safe/070_apply_global_buff_spell_row_reconstruction.sql`
- `database/recovery/audits/15_global_buff_spell_row_recovery_audit.sql`
- `database/recovery/migrations_pending/100_review_global_buff_runtime_activation.sql`
- `recovery/verify_recovery_slice_v11.py`

## Expected after migration

- `spells_new` contains 8 rows for IDs `44000` through `44007`.
- `44001` is `Echo of Power`.
- `Custom:PermanentServerBuffsEnabled` remains `false`.
- Migration ledger contains `070_apply_global_buff_spell_row_reconstruction.sql`.

## Apply

```bash
python3 recovery/verify_recovery_slice_v11.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='your_migrate_password_here'

bash recovery/apply_db_migrations.sh --dry-run
bash recovery/apply_db_migrations.sh
```

Then audit:

```bash
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```
