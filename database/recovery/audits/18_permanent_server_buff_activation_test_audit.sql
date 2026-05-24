-- MSR Recovery Audit 18
-- Permanent server buff activation test state.
-- Read-only. Confirms the DB switch that Spire/operator tooling should toggle.

SELECT
  'audit' AS `section`,
  '18_permanent_server_buff_activation_test' AS `audit_name`,
  NOW() AS `audited_at`;

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
  'activation_summary' AS `section`,
  COUNT(*) AS `rule_rows`,
  SUM(CASE WHEN LOWER(`rule_value`) IN ('true', '1', 'yes', 'on') THEN 1 ELSE 0 END) AS `enabled_rows`,
  SUM(CASE WHEN LOWER(`rule_value`) IN ('false', '0', 'no', 'off') THEN 1 ELSE 0 END) AS `disabled_rows`,
  SUM(CASE WHEN LOWER(`rule_value`) NOT IN ('true', '1', 'yes', 'on', 'false', '0', 'no', 'off') THEN 1 ELSE 0 END) AS `non_booleanish_rows`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled';

SELECT
  'runtime_spell_preconditions' AS `section`,
  COUNT(*) AS `required_runtime_spell_rows_present`,
  SUM(CASE WHEN `id` = 44000 AND `name` = 'Echo of Experience' THEN 1 ELSE 0 END) AS `echo_experience_ok`,
  SUM(CASE WHEN `id` = 44001 AND `name` = 'Echo of Power' THEN 1 ELSE 0 END) AS `echo_power_ok`,
  SUM(CASE WHEN `id` = 44003 AND `name` = 'Echo of Speed' THEN 1 ELSE 0 END) AS `echo_speed_ok`,
  SUM(CASE WHEN `id` = 44007 AND `name` = 'Echo of Luck' THEN 1 ELSE 0 END) AS `echo_luck_ok`
FROM `spells_new`
WHERE `id` IN (44000, 44001, 44003, 44007);
