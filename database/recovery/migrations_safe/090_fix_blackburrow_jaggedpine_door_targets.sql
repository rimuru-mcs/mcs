-- MSR Recovery Slice v17
-- Fix Blackburrow doors incorrectly configured as zone teleports to Jaggedpine.
--
-- Lost update reference:
--   "Fixed Doors in Blackburrow where set to jaggedpines rather than open door making it so you couldnt open doors due to progression lockout."
--
-- Safety posture:
--   * Does NOT delete door rows.
--   * Backs up affected door rows into msr_recovery_blackburrow_door_backup before modification.
--   * Only touches doors in zone='blackburrow' version=0 with dest_zone='jaggedpine'.
--   * Converts the accidental teleport targets into ordinary/open doors by clearing the destination.
--   * Idempotent: reruns should change 0 rows after first successful application.

CREATE TABLE IF NOT EXISTS `msr_recovery_blackburrow_door_backup` AS
SELECT
  NOW() AS `backup_created_at`,
  d.*
FROM `doors` d
WHERE 1 = 0;

INSERT INTO `msr_recovery_blackburrow_door_backup`
SELECT
  NOW() AS `backup_created_at`,
  d.*
FROM `doors` d
WHERE d.`zone` = 'blackburrow'
  AND d.`version` = 0
  AND d.`dest_zone` = 'jaggedpine'
  AND NOT EXISTS (
    SELECT 1
    FROM `msr_recovery_blackburrow_door_backup` b
    WHERE b.`id` = d.`id`
  );

SET @msr_blackburrow_doors_before := (
  SELECT COUNT(*)
  FROM `doors`
  WHERE `zone` = 'blackburrow'
    AND `version` = 0
    AND `dest_zone` = 'jaggedpine'
);

UPDATE `doors`
SET
  `dest_zone` = 'NONE',
  `dest_x` = 0,
  `dest_y` = 0,
  `dest_z` = 0
WHERE `zone` = 'blackburrow'
  AND `version` = 0
  AND `dest_zone` = 'jaggedpine';

SET @msr_blackburrow_doors_changed := ROW_COUNT();

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `applied_by`, `notes`)
SELECT
  '090_fix_blackburrow_jaggedpine_door_targets.sql',
  CURRENT_USER(),
  CONCAT(
    'Cleared accidental Blackburrow door teleport target(s) to Jaggedpine. ',
    'Before=', @msr_blackburrow_doors_before,
    ', changed=', @msr_blackburrow_doors_changed,
    ', backup rows=', (
      SELECT COUNT(*)
      FROM `msr_recovery_blackburrow_door_backup`
      WHERE `zone` = 'blackburrow'
        AND `version` = 0
        AND `dest_zone` = 'jaggedpine'
    ),
    '. Affected doors were backed up before modification.'
  )
WHERE NOT EXISTS (
  SELECT 1
  FROM `msr_recovery_migration_log`
  WHERE `migration_name` = '090_fix_blackburrow_jaggedpine_door_targets.sql'
);
