-- MSR Recovery Audit 17: global buff runtime implementation readiness
-- Confirms DB-side preconditions for enabling the recovered runtime path.

SELECT
  'global_buff_runtime_spell_preconditions' AS `section`,
  COUNT(*) AS `global_buff_rows_present`,
  SUM(CASE WHEN `id` = 44000 AND `name` = 'Echo of Experience' THEN 1 ELSE 0 END) AS `echo_experience_ok`,
  SUM(CASE WHEN `id` = 44001 AND `name` = 'Echo of Power' THEN 1 ELSE 0 END) AS `echo_power_ok`,
  SUM(CASE WHEN `id` = 44003 AND `name` = 'Echo of Speed' THEN 1 ELSE 0 END) AS `echo_speed_ok`,
  SUM(CASE WHEN `id` = 44007 AND `name` = 'Echo of Luck' THEN 1 ELSE 0 END) AS `echo_luck_ok`
FROM `spells_new`
WHERE `id` IN (44000, 44001, 44003, 44007);

SELECT
  'permanent_server_buff_rule_state' AS `section`,
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
ORDER BY `ruleset_id`;

SELECT
  'runtime_activation_still_disabled' AS `section`,
  COUNT(*) AS `rule_rows`,
  SUM(CASE WHEN LOWER(`rule_value`) = 'true' THEN 1 ELSE 0 END) AS `enabled_rows`,
  SUM(CASE WHEN LOWER(`rule_value`) <> 'true' THEN 1 ELSE 0 END) AS `disabled_rows`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled';

SELECT
  'latest_global_buff_runtime_related_migrations' AS `section`,
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` LIKE '%global_buff%'
ORDER BY `applied_at`, `migration_name`;
