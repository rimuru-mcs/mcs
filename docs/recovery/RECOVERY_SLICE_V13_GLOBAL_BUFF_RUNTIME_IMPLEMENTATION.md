# Recovery Slice v13 — Global Buff Runtime Implementation

## Purpose

Slice v12 proved that the restored database now has the missing global buff spell rows, but the source audit did **not** find a real runtime implementation for `Custom:PermanentServerBuffsEnabled` outside recovery docs and migrations.

This slice adds the missing server-side runtime path while keeping the database activation rule disabled.

## Code changes

- Adds `RULE_BOOL(Custom, PermanentServerBuffsEnabled, false, ...)` to `common/ruletypes.h`.
- Adds `Client::ApplyPermanentServerBuffs()` declaration to `zone/client.h`.
- Implements `Client::ApplyPermanentServerBuffs()` in `zone/client_packet.cpp`.
- Calls `ApplyPermanentServerBuffs()` during `Client::CompleteConnect()` after dynamic-zone updates and before the later buff packet refresh path.

## Buff set

The lost 5/23 notes say global buffs were reduced to four and other effects were combined into Echo of Power. The runtime therefore applies only the final four-buff set:

| Spell ID | Spell name |
|---:|---|
| 44000 | Echo of Experience |
| 44001 | Echo of Power |
| 44003 | Echo of Speed |
| 44007 | Echo of Luck |

The other reconstructed spell rows remain in `spells_new` for compatibility/history, but are not automatically applied by this runtime path.

## Safety behavior

- The runtime does nothing unless `RuleB(Custom, PermanentServerBuffsEnabled)` is true.
- Invalid/missing spell rows are skipped and logged.
- Already-active matching buffs are not duplicated.
- Buffs are applied with permanent duration through the existing `ApplySpellBuff(..., -1, level)` path.

## Activation remains pending

This slice does **not** set `Custom:PermanentServerBuffsEnabled=true`.

Use `database/recovery/migrations_pending/120_review_enable_permanent_server_buffs.sql` only after a clean compile and dev-client smoke test.

## Suggested verification

```bash
python3 recovery/verify_recovery_slice_v13.py
```

Then compile the server on Windows/VS2022 or Linux.

After compile, run the normal DB audit:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'

bash recovery/run_db_audit.sh
```

The new audit `17_global_buff_runtime_implementation_audit.sql` should confirm the spell preconditions and show the activation rule is still disabled.
