-- MSR Recovery Slice v16 audit
-- Verifies that Defiant item lootdrop spawn rows are disabled without deleting item rows.

SELECT
  'audit' AS `section`,
  '20_defiant_spawn_cleanup_recovery' AS `audit_name`,
  NOW() AS `audited_at`;

SELECT
  'defiant_spawn_cleanup_summary' AS `section`,
  COUNT(DISTINCT i.`id`) AS `defiant_item_rows`,
  SUM(CASE WHEN lde.`item_id` IS NOT NULL THEN 1 ELSE 0 END) AS `defiant_lootdrop_rows_total`,
  SUM(CASE WHEN lde.`item_id` IS NOT NULL AND lde.`chance` > 0 THEN 1 ELSE 0 END) AS `defiant_lootdrop_rows_still_active`,
  SUM(CASE WHEN lde.`item_id` IS NOT NULL AND lde.`chance` = 0 AND lde.`disabled_chance` > 0 THEN 1 ELSE 0 END) AS `defiant_lootdrop_rows_disabled`,
  (
    SELECT COUNT(*)
    FROM `merchantlist` ml
    JOIN `items` mi ON mi.`id` = ml.`item`
    WHERE mi.`Name` LIKE '%Defiant%'
  ) AS `defiant_merchant_rows`
FROM `items` i
LEFT JOIN `lootdrop_entries` lde ON lde.`item_id` = i.`id`
WHERE i.`Name` LIKE '%Defiant%';

SELECT
  'defiant_active_lootdrop_rows_after' AS `section`,
  lde.`lootdrop_id`,
  lde.`item_id`,
  i.`Name`,
  lde.`chance`,
  lde.`disabled_chance`
FROM `lootdrop_entries` lde
JOIN `items` i ON i.`id` = lde.`item_id`
WHERE i.`Name` LIKE '%Defiant%'
  AND lde.`chance` > 0
ORDER BY lde.`lootdrop_id`, lde.`item_id`
LIMIT 100;

SELECT
  'defiant_disabled_lootdrop_rows_sample' AS `section`,
  lde.`lootdrop_id`,
  lde.`item_id`,
  i.`Name`,
  lde.`chance`,
  lde.`disabled_chance`
FROM `lootdrop_entries` lde
JOIN `items` i ON i.`id` = lde.`item_id`
WHERE i.`Name` LIKE '%Defiant%'
  AND lde.`chance` = 0
  AND lde.`disabled_chance` > 0
ORDER BY lde.`lootdrop_id`, lde.`item_id`
LIMIT 100;

SELECT
  'defiant_cleanup_migration_log' AS `section`,
  `id`,
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '080_disable_defiant_lootdrop_spawn_sources.sql';
