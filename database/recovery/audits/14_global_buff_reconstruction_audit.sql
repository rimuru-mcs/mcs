-- MSR Recovery Slice v10
-- Global buff reconstruction audit.
--
-- This file is READ ONLY. It does not modify database state.
--
-- Purpose:
--   The lost 5/21 and 5/23 notes describe global/server buff work around
--   spell IDs 44000-44007 and a Custom:PermanentServerBuffsEnabled rule.
--   Earlier audits showed those spell rows are absent from this restored DB.
--   This audit gathers the DB-side facts needed before any spell-row recovery
--   migration is promoted.

SELECT
  'audit' AS `section`,
  '14_global_buff_reconstruction' AS `audit_name`,
  NOW() AS `audited_at`;

SELECT
  'rules' AS `section`,
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` IN (
  'Custom:PermanentServerBuffsEnabled',
  'Custom:PermanentServerBuffsNPCID',
  'Custom:ServerBuffsEnabled',
  'Custom:ServerBuffNPCID'
)
ORDER BY `ruleset_id`, `rule_name`;

SELECT
  'spells_exact_ids' AS `section`,
  `id`,
  `name`,
  `classes1`,
  `classes2`,
  `classes3`,
  `classes4`,
  `classes5`,
  `classes6`,
  `classes7`,
  `classes8`,
  `classes9`,
  `classes10`,
  `classes11`,
  `classes12`,
  `classes13`,
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
  `buffduration`,
  `goodEffect`,
  `songcap`
FROM `spells_new`
WHERE `id` BETWEEN 44000 AND 44007
ORDER BY `id`;

SELECT
  'spells_nearby_ids' AS `section`,
  `id`,
  `name`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effect_base_value1`,
  `effect_base_value2`,
  `effect_base_value3`,
  `buffduration`,
  `goodEffect`
FROM `spells_new`
WHERE `id` BETWEEN 43990 AND 44020
ORDER BY `id`;

SELECT
  'spells_echo_names' AS `section`,
  `id`,
  `name`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effectid4`,
  `effectid5`,
  `effect_base_value1`,
  `effect_base_value2`,
  `effect_base_value3`,
  `effect_base_value4`,
  `effect_base_value5`,
  `buffduration`,
  `goodEffect`,
  `songcap`
FROM `spells_new`
WHERE
  `name` LIKE 'Echo of %'
  OR `name` LIKE '%Echo of Power%'
  OR `name` LIKE '%Echo of Experience%'
  OR `name` LIKE '%Echo of Luck%'
ORDER BY `id`
LIMIT 200;

SELECT
  'spell_schema_summary' AS `section`,
  COUNT(*) AS `spells_new_column_count`
FROM `information_schema`.`COLUMNS`
WHERE
  `TABLE_SCHEMA` = DATABASE()
  AND `TABLE_NAME` = 'spells_new';

SELECT
  'spell_schema_columns' AS `section`,
  `ORDINAL_POSITION`,
  `COLUMN_NAME`,
  `COLUMN_TYPE`,
  `IS_NULLABLE`,
  `COLUMN_DEFAULT`
FROM `information_schema`.`COLUMNS`
WHERE
  `TABLE_SCHEMA` = DATABASE()
  AND `TABLE_NAME` = 'spells_new'
ORDER BY `ORDINAL_POSITION`;

SELECT
  'related_tables' AS `section`,
  `TABLE_NAME`
FROM `information_schema`.`TABLES`
WHERE
  `TABLE_SCHEMA` = DATABASE()
  AND (
    `TABLE_NAME` LIKE '%spell%'
    OR `TABLE_NAME` LIKE '%buff%'
    OR `TABLE_NAME` LIKE '%rule%'
  )
ORDER BY `TABLE_NAME`;

SELECT
  'summary' AS `section`,
  (SELECT COUNT(*) FROM `spells_new` WHERE `id` BETWEEN 44000 AND 44007) AS `global_buff_exact_id_rows`,
  (SELECT COUNT(*) FROM `spells_new` WHERE `name` LIKE 'Echo of %') AS `echo_named_spell_rows`,
  (
    SELECT COUNT(*)
    FROM `rule_values`
    WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
  ) AS `permanent_server_buffs_rule_rows`;
