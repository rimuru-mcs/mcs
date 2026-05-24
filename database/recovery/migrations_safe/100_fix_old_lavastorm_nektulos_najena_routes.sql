-- Recovery Slice v22
-- Fix classic/old Nektulos/Lavastorm/Najena route rows while preserving later version rows.
--
-- MSR progression note:
-- This server intentionally keeps old and new versions of Nektulos/Lavastorm.
-- Players start in Classic and unlock later expansion content through progression.
-- Therefore this migration repairs classic/version-0 routing and obvious duplicate
-- PoK old-zone routing, but does not delete or flatten version-1 data.

CREATE TABLE IF NOT EXISTS `msr_recovery_old_zone_route_backup` (
  `backup_id` INT NOT NULL AUTO_INCREMENT,
  `migration_name` VARCHAR(128) NOT NULL,
  `source_table` VARCHAR(64) NOT NULL,
  `source_id` INT NOT NULL,
  `row_payload` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`backup_id`),
  KEY `idx_msr_old_zone_route_backup_source` (`source_table`, `source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `msr_recovery_old_zone_route_backup`
  (`migration_name`, `source_table`, `source_id`, `row_payload`)
SELECT
  '100_fix_old_lavastorm_nektulos_najena_routes.sql',
  'zone_points',
  `id`,
  CONCAT_WS('|',
    `id`, `zone`, `version`, `number`, `target_zone_id`, `target_instance`,
    `x`, `y`, `z`, `heading`, `target_x`, `target_y`, `target_z`, `target_heading`
  )
FROM `zone_points`
WHERE `id` IN (2394, 2398, 1446, 2302, 889, 4502)
  AND NOT EXISTS (
    SELECT 1
    FROM `msr_recovery_old_zone_route_backup` b
    WHERE b.`migration_name` = '100_fix_old_lavastorm_nektulos_najena_routes.sql'
      AND b.`source_table` = 'zone_points'
      AND b.`source_id` = `zone_points`.`id`
  );

INSERT INTO `msr_recovery_old_zone_route_backup`
  (`migration_name`, `source_table`, `source_id`, `row_payload`)
SELECT
  '100_fix_old_lavastorm_nektulos_najena_routes.sql',
  'doors',
  `id`,
  CONCAT_WS('|',
    `id`, `zone`, `version`, `name`, `pos_x`, `pos_y`, `pos_z`, `heading`,
    `dest_zone`, `dest_instance`, `dest_x`, `dest_y`, `dest_z`, `dest_heading`
  )
FROM `doors`
WHERE `id` IN (2057, 17151)
  AND NOT EXISTS (
    SELECT 1
    FROM `msr_recovery_old_zone_route_backup` b
    WHERE b.`migration_name` = '100_fix_old_lavastorm_nektulos_najena_routes.sql'
      AND b.`source_table` = 'doors'
      AND b.`source_id` = `doors`.`id`
  );

-- Lavastorm v0 -> Najena.
-- Old DB row had source trigger at 0,0,0 and did not fire reliably in the old client layout.
-- Client validation placed the old Lavastorm Najena entrance near -943.06, -1045.56, 16.38.
UPDATE `zone_points`
SET
  `x` = -943.06,
  `y` = -1045.56,
  `z` = 16.38,
  `target_x` = 858.00,
  `target_y` = -76.00,
  `target_z` = 4.00,
  `target_heading` = 999
WHERE `id` = 2394
  AND `zone` = 'lavastorm'
  AND `version` = 0
  AND `target_zone_id` = 44;

-- Najena -> Lavastorm.
-- Row 889 landed outside the old Lavastorm map. Row 4502 was closer but duplicate routes
-- should be consistent so whichever row the client/server chooses lands safely.
UPDATE `zone_points`
SET
  `target_x` = -996.63,
  `target_y` = -1007.60,
  `target_z` = 16.40,
  `target_heading` = 999
WHERE `id` IN (889, 4502)
  AND `zone` = 'najena'
  AND `version` = 0
  AND `target_zone_id` = 27;

-- Lavastorm v0 -> Nektulos.
-- Align trigger with old Lavastorm Nektulos zone-line client /loc:
-- x=-196.03, y=-2075.32, z=-15.84.
-- Keep the classic Nektulos target already paired with Nektulos v0 -> Lavastorm.
UPDATE `zone_points`
SET
  `x` = -196.03,
  `y` = -2075.32,
  `z` = -15.84,
  `target_x` = 289.00,
  `target_y` = 3107.00,
  `target_z` = -17.00,
  `target_heading` = 999
WHERE `id` = 2398
  AND `zone` = 'lavastorm'
  AND `version` = 0
  AND `target_zone_id` = 25;

-- Nektulos v0 -> Lavastorm.
-- Make both duplicate classic rows consistent with the observed old Lavastorm arrival.
UPDATE `zone_points`
SET
  `x` = 289.00,
  `y` = 3107.00,
  `z` = -17.00,
  `target_x` = -196.03,
  `target_y` = -2075.32,
  `target_z` = -15.84,
  `target_heading` = 999
WHERE `id` IN (1446, 2302)
  AND `zone` = 'nektulos'
  AND `version` = 0
  AND `target_zone_id` = 27;

-- PoK -> Nektulos.
-- Two overlapping PoK doors target Nektulos; one forced dest_instance=1.
-- For progression-safe old-zone routing, both should land in classic instance 0.
UPDATE `doors`
SET
  `dest_instance` = 0,
  `dest_x` = -349.00,
  `dest_y` = 705.00,
  `dest_z` = -4.00,
  `dest_heading` = 20
WHERE `id` = 2057
  AND `zone` = 'PoKnowledge'
  AND `dest_zone` = 'nektulos';

INSERT INTO `msr_recovery_migration_log`
  (`migration_name`, `notes`)
SELECT
  '100_fix_old_lavastorm_nektulos_najena_routes.sql',
  CONCAT(
    'Patched classic Lavastorm/Nektulos/Najena route rows; ',
    'preserved version-1 routes; forced duplicate PoK->Nektulos door to classic dest_instance=0.'
  )
WHERE NOT EXISTS (
  SELECT 1
  FROM `msr_recovery_migration_log`
  WHERE `migration_name` = '100_fix_old_lavastorm_nektulos_najena_routes.sql'
);
