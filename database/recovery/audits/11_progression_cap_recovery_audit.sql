-- MSR Recovery Audit 11: bucket-backed progression cap recovery verification

SELECT 'audit' AS section, '11_progression_cap_recovery' AS audit_name, NOW() AS audited_at;

SELECT
  `ruleset_id`,
  MAX(CASE WHEN `rule_name` = 'Character:MaxLevel' THEN `rule_value` END) AS max_level,
  MAX(CASE WHEN `rule_name` = 'Character:MaxExpLevel' THEN `rule_value` END) AS max_exp_level,
  MAX(CASE WHEN `rule_name` = 'Character:KeepLevelOverMax' THEN `rule_value` END) AS keep_level_over_max,
  MAX(CASE WHEN `rule_name` = 'Character:PerCharacterBucketMaxLevel' THEN `rule_value` END) AS per_character_bucket_max_level,
  MAX(CASE WHEN `rule_name` = 'Character:PerCharacterQglobalMaxLevel' THEN `rule_value` END) AS per_character_qglobal_max_level
FROM `rule_values`
WHERE `rule_name` IN (
  'Character:MaxLevel',
  'Character:MaxExpLevel',
  'Character:KeepLevelOverMax',
  'Character:PerCharacterBucketMaxLevel',
  'Character:PerCharacterQglobalMaxLevel'
)
GROUP BY `ruleset_id`
ORDER BY `ruleset_id`;

SELECT
  COUNT(*) AS total_rulesets,
  SUM(CASE WHEN rv_bucket.`rule_value` = 'true' THEN 1 ELSE 0 END) AS rulesets_bucket_cap_enabled,
  SUM(CASE WHEN rv_qglobal.`rule_value` = 'false' THEN 1 ELSE 0 END) AS rulesets_qglobal_cap_disabled
FROM `rule_sets` rs
LEFT JOIN `rule_values` rv_bucket
  ON rv_bucket.`ruleset_id` = rs.`ruleset_id`
 AND rv_bucket.`rule_name` = 'Character:PerCharacterBucketMaxLevel'
LEFT JOIN `rule_values` rv_qglobal
  ON rv_qglobal.`ruleset_id` = rs.`ruleset_id`
 AND rv_qglobal.`rule_name` = 'Character:PerCharacterQglobalMaxLevel';

SELECT
  COUNT(*) AS charmax_bucket_rows,
  COUNT(DISTINCT `character_id`) AS bucket_character_count,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS numeric_bucket_rows,
  SUM(CASE WHEN NOT (`value` REGEXP '^[0-9]+$') THEN 1 ELSE 0 END) AS non_numeric_bucket_rows,
  MIN(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS min_bucket_cap,
  MAX(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS max_bucket_cap
FROM `data_buckets`
WHERE `key` = 'CharMaxLevel';

SELECT
  COUNT(*) AS charmax_qglobal_rows,
  COUNT(DISTINCT `charid`) AS qglobal_character_count,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS numeric_qglobal_rows,
  SUM(CASE WHEN NOT (`value` REGEXP '^[0-9]+$') THEN 1 ELSE 0 END) AS non_numeric_qglobal_rows
FROM `quest_globals`
WHERE `name` = 'CharMaxLevel';

SELECT
  cd.`id`,
  cd.`name`,
  cd.`level`,
  db.`value` AS bucket_char_max_level,
  CASE
    WHEN db.`value` IS NULL THEN 'NO_BUCKET_CAP'
    WHEN NOT (db.`value` REGEXP '^[0-9]+$') THEN 'NON_NUMERIC_BUCKET_CAP'
    WHEN cd.`level` > CAST(db.`value` AS UNSIGNED) THEN 'LEVEL_ABOVE_BUCKET_CAP'
    WHEN cd.`level` = CAST(db.`value` AS UNSIGNED) THEN 'AT_BUCKET_CAP'
    ELSE 'BELOW_BUCKET_CAP'
  END AS bucket_cap_status
FROM `character_data` cd
LEFT JOIN `data_buckets` db
  ON db.`character_id` = cd.`id`
 AND db.`key` = 'CharMaxLevel'
ORDER BY
  CASE
    WHEN db.`value` IS NULL THEN 2
    WHEN NOT (db.`value` REGEXP '^[0-9]+$') THEN 0
    WHEN cd.`level` > CAST(db.`value` AS UNSIGNED) THEN 0
    ELSE 1
  END,
  cd.`level` DESC,
  cd.`id`
LIMIT 100;

SELECT
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '050_apply_bucket_progression_cap_recovery.sql';
