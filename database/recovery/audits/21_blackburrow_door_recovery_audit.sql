-- MSR Recovery Slice v17 audit
-- Verifies that Blackburrow doors no longer teleport to Jaggedpine.

SELECT
  'audit' AS `section`,
  '21_blackburrow_door_recovery' AS `audit_name`,
  NOW() AS `audited_at`;

SELECT
  'blackburrow_door_recovery_summary' AS `section`,
  SUM(CASE WHEN `zone` = 'blackburrow' AND `version` = 0 THEN 1 ELSE 0 END) AS `blackburrow_version0_doors`,
  SUM(CASE WHEN `zone` = 'blackburrow' AND `version` = 0 AND `dest_zone` = 'jaggedpine' THEN 1 ELSE 0 END) AS `blackburrow_doors_still_targeting_jaggedpine`,
  SUM(CASE WHEN `zone` = 'blackburrow' AND `version` = 0 AND `dest_zone` = 'NONE' THEN 1 ELSE 0 END) AS `blackburrow_version0_open_or_none_doors`
FROM `doors`;

SELECT
  'blackburrow_jaggedpine_doors_after' AS `section`,
  `id`,
  `doorid`,
  `zone`,
  `version`,
  `name`,
  `opentype`,
  `keyitem`,
  `lockpick`,
  `dest_zone`,
  `dest_x`,
  `dest_y`,
  `dest_z`,
  `min_expansion`,
  `max_expansion`,
  `content_flags`,
  `content_flags_disabled`
FROM `doors`
WHERE `zone` = 'blackburrow'
  AND `version` = 0
  AND `dest_zone` = 'jaggedpine'
ORDER BY `doorid`, `id`;

SELECT
  'blackburrow_recovered_door_sample' AS `section`,
  `id`,
  `doorid`,
  `zone`,
  `version`,
  `name`,
  `opentype`,
  `keyitem`,
  `lockpick`,
  `dest_zone`,
  `dest_x`,
  `dest_y`,
  `dest_z`,
  `min_expansion`,
  `max_expansion`,
  `content_flags`,
  `content_flags_disabled`
FROM `doors`
WHERE `zone` = 'blackburrow'
  AND `version` = 0
  AND `dest_zone` = 'NONE'
ORDER BY `doorid`, `id`
LIMIT 100;

SELECT
  'blackburrow_door_backup_summary' AS `section`,
  COUNT(*) AS `backup_rows`
FROM `msr_recovery_blackburrow_door_backup`
WHERE `zone` = 'blackburrow'
  AND `version` = 0
  AND `dest_zone` = 'jaggedpine';

SELECT
  'blackburrow_door_migration_log' AS `section`,
  `id`,
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '090_fix_blackburrow_jaggedpine_door_targets.sql';
