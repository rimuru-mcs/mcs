-- MSR Recovery Slice v11
-- Global buff spell-row recovery audit.
--
-- This file is READ ONLY. It does not modify database state.

SELECT
  'audit' AS `section`,
  '15_global_buff_spell_row_recovery' AS `audit_name`,
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
  'global_buff_rows' AS `section`,
  `id`,
  `name`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effectid4`,
  `effectid5`,
  `effectid6`,
  `effect_base_value1`,
  `effect_base_value2`,
  `effect_base_value3`,
  `effect_base_value4`,
  `effect_base_value5`,
  `effect_base_value6`,
  `buffdurationformula`,
  `buffduration`,
  `goodEffect`,
  `songcap`,
  `persistdeath`
FROM `spells_new`
WHERE `id` BETWEEN 44000 AND 44007
ORDER BY `id`;

SELECT
  'global_buff_summary' AS `section`,
  COUNT(*) AS `global_buff_rows_present`,
  SUM(CASE WHEN `name` = 'Echo of Experience' THEN 1 ELSE 0 END) AS `echo_experience_rows`,
  SUM(CASE WHEN `name` = 'Echo of Power' THEN 1 ELSE 0 END) AS `echo_power_rows`,
  SUM(CASE WHEN `name` = 'Echo of Statistics' THEN 1 ELSE 0 END) AS `echo_statistics_rows`,
  SUM(CASE WHEN `name` = 'Echo of Speed' THEN 1 ELSE 0 END) AS `echo_speed_rows`,
  SUM(CASE WHEN `name` = 'Echo of Mana' THEN 1 ELSE 0 END) AS `echo_mana_rows`,
  SUM(CASE WHEN `name` = 'Echo of Haste' THEN 1 ELSE 0 END) AS `echo_haste_rows`,
  SUM(CASE WHEN `name` = 'Echo of Health' THEN 1 ELSE 0 END) AS `echo_health_rows`,
  SUM(CASE WHEN `name` = 'Echo of Luck' THEN 1 ELSE 0 END) AS `echo_luck_rows`
FROM `spells_new`
WHERE `id` BETWEEN 44000 AND 44007;

SELECT
  'global_buff_rule' AS `section`,
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
ORDER BY `ruleset_id`;

SELECT
  'activation_safety' AS `section`,
  SUM(CASE WHEN `rule_value` = 'true' THEN 1 ELSE 0 END) AS `enabled_rule_rows`,
  SUM(CASE WHEN `rule_value` <> 'true' THEN 1 ELSE 0 END) AS `disabled_or_nontrue_rule_rows`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled';
