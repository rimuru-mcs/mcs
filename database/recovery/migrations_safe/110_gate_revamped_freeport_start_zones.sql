-- Recovery Slice v27 safe migration: gate revamped Freeport start-zone rows.
--
-- Why:
--   The recovered DB can select freeportwest / zone 383 for new characters before that
--   revamped Freeport path is actually usable in the recovered runtime. This causes
--   character creation to succeed but world entry to fail with "That zone is unavailable."
--
-- Design doctrine:
--   - Do not delete revamped Freeport rows.
--   - Do not block expansion-native races/classes from existing.
--   - Do not flatten every start into Classic-only cities.
--   - Gate only revamped Freeport start rows behind an explicit content flag so old/default
--     city rows and Crescent/sanctuary starts can be selected normally.
--
-- Rollback note:
--   Original start_zones rows are copied to msr_recovery_start_zone_v27_backup before update.

CREATE TABLE IF NOT EXISTS `msr_recovery_start_zone_v27_backup` AS
SELECT *
FROM `start_zones`
WHERE 1 = 0;

INSERT INTO `msr_recovery_start_zone_v27_backup`
SELECT sz.*
FROM `start_zones` sz
LEFT JOIN `zone` zone_by_zone_id ON zone_by_zone_id.`zoneidnumber` = sz.`zone_id`
LEFT JOIN `zone` zone_by_start_zone ON zone_by_start_zone.`zoneidnumber` = sz.`start_zone`
WHERE sz.`zone_id` IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR sz.`start_zone` IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR zone_by_zone_id.`short_name` IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
   OR zone_by_start_zone.`short_name` IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   );

UPDATE `start_zones` sz
LEFT JOIN `zone` zone_by_zone_id ON zone_by_zone_id.`zoneidnumber` = sz.`zone_id`
LEFT JOIN `zone` zone_by_start_zone ON zone_by_start_zone.`zoneidnumber` = sz.`start_zone`
SET sz.`content_flags` = 'msr_revamped_freeport_unlocked'
WHERE (
      sz.`zone_id` IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR sz.`start_zone` IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR zone_by_zone_id.`short_name` IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
   OR zone_by_start_zone.`short_name` IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
)
AND (sz.`content_flags` IS NULL OR sz.`content_flags` = '' OR sz.`content_flags` <> 'msr_revamped_freeport_unlocked');

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '110_gate_revamped_freeport_start_zones.sql',
    CONCAT(
      'Gated revamped Freeport start_zones behind msr_revamped_freeport_unlocked; backed up rows=',
      (SELECT COUNT(*) FROM `msr_recovery_start_zone_v27_backup`)
    )
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
