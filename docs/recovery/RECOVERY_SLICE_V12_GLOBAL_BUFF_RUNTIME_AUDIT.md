# MSR Recovery Slice v12 — Global Buff Runtime Audit

## Purpose

Slice v11 reconstructed the missing global buff spell rows `44000` through `44007`, but deliberately kept `Custom:PermanentServerBuffsEnabled` disabled.

Slice v12 adds audit tooling to determine whether the server source actually contains a safe runtime path for applying those buffs.

## Safety posture

This slice is read-only.

It does **not**:

- enable `Custom:PermanentServerBuffsEnabled`,
- modify spell rows,
- modify character buffs,
- modify items,
- alter runtime behavior.

## Files added

- `database/recovery/audits/16_global_buff_runtime_readiness_audit.sql`
- `database/recovery/migrations_pending/110_review_global_buff_runtime_code_path.sql`
- `recovery/audit_global_buff_runtime_code.py`
- `recovery/verify_recovery_slice_v12.py`

## Verify

```bash
python3 recovery/verify_recovery_slice_v12.py
```

## Run DB-side readiness audit

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
```

## Run source-code runtime audit

```bash
python3 recovery/audit_global_buff_runtime_code.py
```

This writes:

- `database/recovery/code_audit_output/global_buff_runtime_code_audit.txt`
- `database/recovery/code_audit_output/global_buff_runtime_code_audit.json`

## Package output

```bash
tar -czf /opt/msr/logs/msr_global_buff_runtime_audit_$(date +%Y%m%d_%H%M%S).tar.gz \
  database/recovery/audit_output \
  database/recovery/code_audit_output
```

## Expected decision point

If the code audit finds no direct reference to `Custom:PermanentServerBuffsEnabled`, spell IDs `44000`-`44007`, or the Echo spell names, then the next slice should be a code implementation/audit slice, not a DB activation slice.

If a concrete runtime path is found, the next slice should inspect that code path before enabling the rule.
