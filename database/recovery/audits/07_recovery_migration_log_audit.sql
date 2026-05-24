-- MSR Recovery Audit 07: safe migration ledger and neutral placeholder verification
-- Run after applying migrations_safe to confirm the recovery ledger and disabled rule placeholder exist.

SELECT 'audit' AS section, '07_recovery_migration_log' AS audit_name, NOW() AS audited_at;

SELECT
  table_name,
  table_rows,
  engine,
  table_collation
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name = 'msr_recovery_migration_log';

SELECT
  id,
  migration_name,
  applied_at,
  applied_by,
  notes
FROM msr_recovery_migration_log
ORDER BY id;

SELECT
  ruleset_id,
  rule_name,
  rule_value,
  notes
FROM rule_values
WHERE rule_name = 'Custom:PermanentServerBuffsEnabled'
ORDER BY ruleset_id;
