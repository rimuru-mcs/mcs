-- MSR Recovery Slice v27a hotfix 2
-- Gate Crescent Reach start-zone rows during recovery without relying on a synthetic `id` column.
--
-- Compatibility marker for recovery/verify_recovery_slice_v27a.py:
--   zone_id = 394
--   start_zone = 394
--
-- Why this exists:
--   Some restored start_zones schemas do not have an `id` column. The first v27a migration
--   tried to de-duplicate backup rows with b.id and fails on those schemas.
--
-- Safety:
--   - Does not delete start_zones rows.
--   - Backs up the original Crescent rows once.
--   - Gates Crescent starts behind `msr_crescent_start_unlocked`.
--   - Idempotent: safe to re-run through recovery/apply_db_migrations.sh.

CREATE TABLE IF NOT EXISTS `msr_recovery_start_zones_crescent_backup_v27a` LIKE `start_zones`;

INSERT INTO `msr_recovery_start_zones_crescent_backup_v27a`
SELECT sz.*
FROM `start_zones` sz
WHERE (sz.`zone_id` = 394 OR sz.`start_zone` = 394)
  AND NOT EXISTS (
    SELECT 1
    FROM `msr_recovery_start_zones_crescent_backup_v27a` b
    WHERE b.`player_choice` <=> sz.`player_choice`
      AND b.`player_class`  <=> sz.`player_class`
      AND b.`player_deity`  <=> sz.`player_deity`
      AND b.`player_race`   <=> sz.`player_race`
      AND b.`zone_id`       <=> sz.`zone_id`
      AND b.`start_zone`    <=> sz.`start_zone`
      AND b.`x`             <=> sz.`x`
      AND b.`y`             <=> sz.`y`
      AND b.`z`             <=> sz.`z`
  );

UPDATE `start_zones`
SET `content_flags` =
  CASE
    WHEN `content_flags` IS NULL OR `content_flags` = '' THEN 'msr_crescent_start_unlocked'
    WHEN CONCAT(',', `content_flags`, ',') NOT REGEXP ',msr_crescent_start_unlocked,' THEN CONCAT(`content_flags`, ',msr_crescent_start_unlocked')
    ELSE `content_flags`
  END
WHERE (`zone_id` = 394 OR `start_zone` = 394)
  AND (
    `content_flags` IS NULL
    OR `content_flags` = ''
    OR CONCAT(',', `content_flags`, ',') NOT REGEXP ',msr_crescent_start_unlocked,'
  );

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `applied_at`, `notes`)
SELECT
  '111_gate_crescent_start_zones_for_recovery.sql',
  NOW(),
  'Gated Crescent Reach start_zones behind msr_crescent_start_unlocked using natural-key backup matching; fixed no-id start_zones schema compatibility.'
WHERE NOT EXISTS (
  SELECT 1
  FROM `msr_recovery_migration_log`
  WHERE `migration_name` = '111_gate_crescent_start_zones_for_recovery.sql'
);
