-- MSR Recovery Safe Migration 010
-- Adds neutral placeholder rules used by recovered code paths.
-- These are intentionally conservative and should not enable gameplay behavior by themselves.

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (1, 'Custom:PermanentServerBuffsEnabled', 'false', 'MSR recovery placeholder. Added from lost 5/23 update notes; kept disabled until global buff code/spells are verified.')
ON DUPLICATE KEY UPDATE
  `notes` = CONCAT(COALESCE(`notes`, ''), ' | MSR recovery saw this rule during Slice v2; value preserved.');

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES ('010_add_neutral_recovery_rule_placeholders.sql', 'Added neutral Custom:PermanentServerBuffsEnabled placeholder if missing; existing value preserved.')
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
