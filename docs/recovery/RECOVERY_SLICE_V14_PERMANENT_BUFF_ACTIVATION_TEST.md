# Recovery Slice v14 — Permanent Server Buff Activation Test Tools

This slice adds controlled dev/test tooling for `Custom:PermanentServerBuffsEnabled`.

The rule is intended to be a Spire/operator switch. For that reason, this slice does **not** add an always-on safe migration. Instead, it adds manual dev-only toggle scripts so runtime behavior can be tested without forcing the rule on in every restored database.

## Added files

- `database/recovery/audits/18_permanent_server_buff_activation_test_audit.sql`
- `database/recovery/manual_tests/enable_permanent_server_buffs_dev_only.sql`
- `database/recovery/manual_tests/disable_permanent_server_buffs_dev_only.sql`
- `recovery/set_permanent_server_buffs.sh`
- `recovery/set_permanent_server_buffs.ps1`
- `recovery/verify_recovery_slice_v14.py`

## Expected runtime prerequisites

Slice v13 must compile successfully and the DB should contain these spell rows:

- `44000` — Echo of Experience
- `44001` — Echo of Power
- `44003` — Echo of Speed
- `44007` — Echo of Luck

The C++ runtime path applies these four spells only when `RuleB(Custom, PermanentServerBuffsEnabled)` is true.

## Linux usage

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v14.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_migrate
export MSR_DB_PASSWORD='msrtest'

bash recovery/set_permanent_server_buffs.sh status
bash recovery/set_permanent_server_buffs.sh on
bash recovery/set_permanent_server_buffs.sh status
```

After runtime testing, disable it again:

```bash
bash recovery/set_permanent_server_buffs.sh off
```

## Audit

Run the normal DB audit after toggling:

```bash
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'
bash recovery/run_db_audit.sh
```

Review:

- `database/recovery/audit_output/18_permanent_server_buff_activation_test_audit.txt`
- `database/recovery/audit_output/17_global_buff_runtime_implementation_audit.txt`

## Safety notes

- This slice does not modify `migrations_safe`.
- This slice does not enable the rule automatically.
- This slice intentionally treats the DB value as a dev/operator/Spire-controlled switch.
- Depending on rule reload behavior, toggling in DB may require `#rules reload`, a zone restart, or full world/zone restart before runtime behavior changes.
