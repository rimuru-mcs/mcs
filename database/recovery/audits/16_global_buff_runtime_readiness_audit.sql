-- MSR Recovery Slice v12
-- Global buff runtime readiness DB audit.
--
-- This file is READ ONLY. It does not modify database state.
-- It verifies the DB-side preconditions before any future runtime activation.

SELECT
  'audit' AS `section`,
  '16_global_buff_runtime_readiness' AS `audit_name`,
  NOW() AS `audited_at`;

SELECT
  'migration_log' AS `section`,
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '070_apply_global_buff_spell_row_reconstruction.sql';

SELECT
  'spell_row_preconditions' AS `section`,
  COUNT(*) AS `global_buff_rows_present`,
  SUM(CASE WHEN `id` = 44000 AND `name` = 'Echo of Experience' THEN 1 ELSE 0 END) AS `echo_experience_ok`,
  SUM(CASE WHEN `id` = 44001 AND `name` = 'Echo of Power' THEN 1 ELSE 0 END) AS `echo_power_ok`,
  SUM(CASE WHEN `id` = 44002 AND `name` = 'Echo of Statistics' THEN 1 ELSE 0 END) AS `echo_statistics_ok`,
  SUM(CASE WHEN `id` = 44003 AND `name` = 'Echo of Speed' THEN 1 ELSE 0 END) AS `echo_speed_ok`,
  SUM(CASE WHEN `id` = 44004 AND `name` = 'Echo of Mana' THEN 1 ELSE 0 END) AS `echo_mana_ok`,
  SUM(CASE WHEN `id` = 44005 AND `name` = 'Echo of Haste' THEN 1 ELSE 0 END) AS `echo_haste_ok`,
  SUM(CASE WHEN `id` = 44006 AND `name` = 'Echo of Health' THEN 1 ELSE 0 END) AS `echo_health_ok`,
  SUM(CASE WHEN `id` = 44007 AND `name` = 'Echo of Luck' THEN 1 ELSE 0 END) AS `echo_luck_ok`
FROM `spells_new`
WHERE `id` BETWEEN 44000 AND 44007;

SELECT
  'spell_row_details' AS `section`,
  `id`,
  `name`,
  `goodEffect`,
  `targettype`,
  `buffdurationformula`,
  `buffduration`,
  `songcap`,
  `persistdeath`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effectid4`,
  `effectid5`,
  `effectid6`,
  `max1`,
  `max2`,
  `max3`,
  `max4`,
  `max5`,
  `max6`
FROM `spells_new`
WHERE `id` BETWEEN 44000 AND 44007
ORDER BY `id`;

SELECT
  'activation_rule_safety' AS `section`,
  COUNT(*) AS `rule_rows`,
  SUM(CASE WHEN `rule_value` = 'true' THEN 1 ELSE 0 END) AS `enabled_rows`,
  SUM(CASE WHEN `rule_value` <> 'true' THEN 1 ELSE 0 END) AS `disabled_or_nontrue_rows`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled';

SELECT
  'activation_rule_details' AS `section`,
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
ORDER BY `ruleset_id`;
