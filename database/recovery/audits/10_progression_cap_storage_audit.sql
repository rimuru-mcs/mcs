-- MSR Recovery Audit 10: progression max-level storage and enforcement readiness
-- Purpose:
--   The lost 5/21 notes say players could level past their progression max.
--   The server code supports two mutually-exclusive per-character cap sources:
--     Character:PerCharacterQglobalMaxLevel  -> quest_globals name='CharMaxLevel'
--     Character:PerCharacterBucketMaxLevel   -> data_buckets key='CharMaxLevel'
--   The code checks qglobal first if enabled, otherwise bucket. Do not enable both blindly.

SELECT 'audit' AS section, '10_progression_cap_storage' AS audit_name, NOW() AS audited_at;

SELECT
  `table_name`,
  `table_rows`,
  `engine`,
  `table_collation`
FROM `information_schema`.`TABLES`
WHERE `table_schema` = DATABASE()
  AND `table_name` IN (
    'rule_sets',
    'rule_values',
    'character_data',
    'data_buckets',
    'quest_globals'
  )
ORDER BY `table_name`;

SELECT
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` IN (
  'Character:MaxLevel',
  'Character:MaxExpLevel',
  'Character:KeepLevelOverMax',
  'Character:SkillCapMaxLevel',
  'Character:PerCharacterBucketMaxLevel',
  'Character:PerCharacterQglobalMaxLevel'
)
ORDER BY `ruleset_id`, `rule_name`;

SELECT
  COUNT(*) AS character_count,
  MIN(`level`) AS min_level,
  MAX(`level`) AS max_level,
  SUM(CASE WHEN `level` > 70 THEN 1 ELSE 0 END) AS characters_above_level_70,
  SUM(CASE WHEN `level` > 68 THEN 1 ELSE 0 END) AS characters_above_level_68,
  SUM(CASE WHEN `level` > 0 THEN 1 ELSE 0 END) AS characters_with_positive_level
FROM `character_data`;

SELECT
  COUNT(*) AS charmax_bucket_rows,
  COUNT(DISTINCT `character_id`) AS bucket_character_count,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS numeric_bucket_rows,
  SUM(CASE WHEN NOT (`value` REGEXP '^[0-9]+$') THEN 1 ELSE 0 END) AS non_numeric_bucket_rows,
  MIN(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS min_bucket_cap,
  MAX(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS max_bucket_cap,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' AND CAST(`value` AS UNSIGNED) = 0 THEN 1 ELSE 0 END) AS zero_bucket_caps,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' AND CAST(`value` AS UNSIGNED) > 70 THEN 1 ELSE 0 END) AS bucket_caps_above_70
FROM `data_buckets`
WHERE `key` = 'CharMaxLevel';

SELECT
  COUNT(*) AS charmax_qglobal_rows,
  COUNT(DISTINCT `charid`) AS qglobal_character_count,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS numeric_qglobal_rows,
  SUM(CASE WHEN NOT (`value` REGEXP '^[0-9]+$') THEN 1 ELSE 0 END) AS non_numeric_qglobal_rows,
  MIN(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS min_qglobal_cap,
  MAX(CASE WHEN `value` REGEXP '^[0-9]+$' THEN CAST(`value` AS UNSIGNED) END) AS max_qglobal_cap,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' AND CAST(`value` AS UNSIGNED) = 0 THEN 1 ELSE 0 END) AS zero_qglobal_caps,
  SUM(CASE WHEN `value` REGEXP '^[0-9]+$' AND CAST(`value` AS UNSIGNED) > 70 THEN 1 ELSE 0 END) AS qglobal_caps_above_70
FROM `quest_globals`
WHERE `name` = 'CharMaxLevel';

SELECT
  c.`id`,
  c.`name`,
  c.`level`,
  b.`value` AS bucket_char_max_level,
  CASE
    WHEN b.`value` REGEXP '^[0-9]+$' AND c.`level` > CAST(b.`value` AS UNSIGNED) THEN 'LEVEL_ABOVE_BUCKET_CAP'
    WHEN b.`value` REGEXP '^[0-9]+$' THEN 'OK_OR_AT_CAP'
    ELSE 'NON_NUMERIC_BUCKET_CAP'
  END AS bucket_cap_status
FROM `character_data` c
JOIN `data_buckets` b
  ON b.`character_id` = c.`id`
 AND b.`key` = 'CharMaxLevel'
ORDER BY c.`level` DESC, c.`id`
LIMIT 100;

SELECT
  c.`id`,
  c.`name`,
  c.`level`,
  q.`value` AS qglobal_char_max_level,
  q.`zoneid`,
  q.`npcid`,
  q.`expdate`,
  CASE
    WHEN q.`value` REGEXP '^[0-9]+$' AND c.`level` > CAST(q.`value` AS UNSIGNED) THEN 'LEVEL_ABOVE_QGLOBAL_CAP'
    WHEN q.`value` REGEXP '^[0-9]+$' THEN 'OK_OR_AT_CAP'
    ELSE 'NON_NUMERIC_QGLOBAL_CAP'
  END AS qglobal_cap_status
FROM `character_data` c
JOIN `quest_globals` q
  ON q.`charid` = c.`id`
 AND q.`name` = 'CharMaxLevel'
ORDER BY c.`level` DESC, c.`id`
LIMIT 100;

SELECT
  'bucket' AS cap_source,
  b.`value` AS cap_value,
  COUNT(*) AS row_count
FROM `data_buckets` b
WHERE b.`key` = 'CharMaxLevel'
GROUP BY b.`value`
UNION ALL
SELECT
  'qglobal' AS cap_source,
  q.`value` AS cap_value,
  COUNT(*) AS row_count
FROM `quest_globals` q
WHERE q.`name` = 'CharMaxLevel'
GROUP BY q.`value`
ORDER BY cap_source, cap_value;
