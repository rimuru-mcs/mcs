-- Recovery Slice v22 audit
-- Verify classic old-zone route recovery rows and progression-safe preservation.

SELECT
  'v22_route_migration_ledger' AS section,
  `migration_name`,
  `applied_at`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '100_fix_old_lavastorm_nektulos_najena_routes.sql';

SELECT
  'v22_backup_rows' AS section,
  `source_table`,
  COUNT(*) AS backup_rows
FROM `msr_recovery_old_zone_route_backup`
WHERE `migration_name` = '100_fix_old_lavastorm_nektulos_najena_routes.sql'
GROUP BY `source_table`
ORDER BY `source_table`;

SELECT
  'v22_lavastorm_nektulos_najena_zone_points' AS section,
  zp.`id`,
  zp.`zone`,
  zp.`version`,
  zp.`number`,
  zp.`target_zone_id`,
  target_zone.`short_name` AS target_short_name,
  zp.`target_instance`,
  zp.`x`,
  zp.`y`,
  zp.`z`,
  zp.`heading`,
  zp.`target_x`,
  zp.`target_y`,
  zp.`target_z`,
  zp.`target_heading`
FROM `zone_points` zp
LEFT JOIN `zone` target_zone
  ON target_zone.`zoneidnumber` = zp.`target_zone_id`
WHERE zp.`id` IN (2394, 2398, 1446, 2302, 889, 4502, 1588, 1879, 4504, 1476)
ORDER BY zp.`zone`, zp.`version`, zp.`id`;

SELECT
  'v22_pok_nektulos_doors' AS section,
  d.`id`,
  d.`zone`,
  d.`version`,
  d.`name`,
  d.`dest_zone`,
  d.`dest_instance`,
  d.`dest_x`,
  d.`dest_y`,
  d.`dest_z`,
  d.`dest_heading`
FROM `doors` d
WHERE d.`zone` = 'PoKnowledge'
  AND d.`dest_zone` = 'nektulos'
ORDER BY d.`id`;

SELECT
  'v22_expected_flags' AS section,
  SUM(CASE WHEN zp.`id` = 2394 AND zp.`x` <> 0 AND zp.`y` <> 0 THEN 1 ELSE 0 END) AS lavastorm_to_najena_trigger_moved,
  SUM(CASE WHEN zp.`id` IN (889, 4502) AND ABS(zp.`target_x` - -996.63) < 1 AND ABS(zp.`target_y` - -1007.60) < 1 THEN 1 ELSE 0 END) AS najena_to_lavastorm_rows_fixed,
  SUM(CASE WHEN zp.`id` = 2398 AND ABS(zp.`x` - -196.03) < 1 AND ABS(zp.`y` - -2075.32) < 1 THEN 1 ELSE 0 END) AS lavastorm_to_nektulos_trigger_moved,
  SUM(CASE WHEN zp.`id` IN (1446, 2302) AND ABS(zp.`target_x` - -196.03) < 1 AND ABS(zp.`target_y` - -2075.32) < 1 THEN 1 ELSE 0 END) AS nektulos_to_lavastorm_rows_fixed
FROM `zone_points` zp
WHERE zp.`id` IN (2394, 2398, 1446, 2302, 889, 4502);

SELECT
  'v22_pok_new_instance_doors_remaining' AS section,
  COUNT(*) AS pok_nektulos_dest_instance_1_rows
FROM `doors`
WHERE `zone` = 'PoKnowledge'
  AND `dest_zone` = 'nektulos'
  AND `dest_instance` = 1;

SELECT
  'v22_version_one_rows_preserved' AS section,
  COUNT(*) AS preserved_version_one_route_rows
FROM `zone_points`
WHERE `id` IN (1588, 1879, 4504, 1476)
  AND `version` = 1;
