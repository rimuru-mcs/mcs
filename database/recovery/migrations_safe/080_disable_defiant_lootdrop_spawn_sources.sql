-- MSR Recovery Slice v16
-- Disable Defiant item lootdrop spawn sources without deleting item rows or loottable links.
--
-- Lost update reference: "Fixed an issue that was allowing defiant gear to spawn in game"
--
-- Safety posture:
--   * Does NOT delete items.
--   * Does NOT delete lootdrop_entries.
--   * Does NOT delete loottable_entries.
--   * Does NOT touch merchants; v15 audit found zero Defiant merchant entries.
--   * Preserves each active chance value in disabled_chance when disabled_chance is 0.
--   * Sets active chance to 0 for Defiant item lootdrop entries only.
--   * Idempotent: reruns should change 0 rows after first successful application.

CREATE TEMPORARY TABLE IF NOT EXISTS `msr_recovery_defiant_item_ids` (
  `item_id` INT(11) NOT NULL PRIMARY KEY
) ENGINE=MEMORY;

TRUNCATE TABLE `msr_recovery_defiant_item_ids`;

INSERT IGNORE INTO `msr_recovery_defiant_item_ids` (`item_id`)
SELECT `id`
FROM `items`
WHERE `Name` LIKE '%Defiant%';

CREATE TEMPORARY TABLE IF NOT EXISTS `msr_recovery_defiant_lootdrop_before` (
  `active_rows_before` INT NOT NULL,
  `linked_rows_before` INT NOT NULL,
  `merchant_rows_before` INT NOT NULL
) ENGINE=MEMORY;

TRUNCATE TABLE `msr_recovery_defiant_lootdrop_before`;

INSERT INTO `msr_recovery_defiant_lootdrop_before`
SELECT
  (
    SELECT COUNT(*)
    FROM `lootdrop_entries` lde
    JOIN `msr_recovery_defiant_item_ids` d ON d.`item_id` = lde.`item_id`
    WHERE lde.`chance` > 0
  ) AS `active_rows_before`,
  (
    SELECT COUNT(*)
    FROM `loottable_entries` lte
    JOIN `lootdrop_entries` lde ON lde.`lootdrop_id` = lte.`lootdrop_id`
    JOIN `msr_recovery_defiant_item_ids` d ON d.`item_id` = lde.`item_id`
  ) AS `linked_rows_before`,
  (
    SELECT COUNT(*)
    FROM `merchantlist` ml
    JOIN `msr_recovery_defiant_item_ids` d ON d.`item_id` = ml.`item`
  ) AS `merchant_rows_before`;

UPDATE `lootdrop_entries` lde
JOIN `msr_recovery_defiant_item_ids` d ON d.`item_id` = lde.`item_id`
SET
  lde.`disabled_chance` = CASE
    WHEN lde.`disabled_chance` = 0 THEN lde.`chance`
    ELSE lde.`disabled_chance`
  END,
  lde.`chance` = 0
WHERE lde.`chance` > 0;

SET @msr_defiant_rows_changed := ROW_COUNT();

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `applied_by`, `notes`)
SELECT
  '080_disable_defiant_lootdrop_spawn_sources.sql',
  CURRENT_USER(),
  CONCAT(
    'Disabled active Defiant lootdrop spawn source row(s). ',
    'Before active lootdrop rows=',
    `active_rows_before`,
    ', linked loottable rows=',
    `linked_rows_before`,
    ', merchant rows=',
    `merchant_rows_before`,
    ', changed=',
    @msr_defiant_rows_changed,
    '. Item rows and loottable links were preserved; chance moved to disabled_chance where needed.'
  )
FROM `msr_recovery_defiant_lootdrop_before`
WHERE NOT EXISTS (
  SELECT 1
  FROM `msr_recovery_migration_log`
  WHERE `migration_name` = '080_disable_defiant_lootdrop_spawn_sources.sql'
);

DROP TEMPORARY TABLE IF EXISTS `msr_recovery_defiant_lootdrop_before`;
DROP TEMPORARY TABLE IF EXISTS `msr_recovery_defiant_item_ids`;
