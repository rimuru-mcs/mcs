-- MSR Recovery Safe Migration 060
-- Removes item-level gates from Sympathetic proc/focus/worn effects.
--
-- Lost 5/23 notes mention:
--   "Fixed Sympathetic items now proc at all levels not just level 70"
--
-- Slice v8 promotes the low-risk DB half of that fix after Audit 04 repeatedly showed
-- sympathetic item rows still carrying non-zero proc/worn/focus level gates.
--
-- Recovery posture:
--   - Only touches item effect level gates attached to spells whose name contains "Sympathetic".
--   - Does NOT alter item required level, recommended level, class masks, slots, prices, or effects.
--   - Does NOT add Sympathetic Strike I to Simple Ring of the Hero yet; that remains pending until
--     the exact intended item/spell pairing is confirmed.

DROP TEMPORARY TABLE IF EXISTS `msr_recovery_sympathetic_spell_ids`;
CREATE TEMPORARY TABLE `msr_recovery_sympathetic_spell_ids` AS
SELECT `id`
FROM `spells_new`
WHERE `name` LIKE '%Sympathetic%';

SET @msr_sympathetic_level_gated_rows_before := (
  SELECT COUNT(*)
  FROM `items`
  WHERE (
      `proceffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
      OR `worneffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
      OR `focuseffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
    )
    AND (
      COALESCE(`proclevel`, 0) > 0 OR COALESCE(`proclevel2`, 0) > 0 OR
      COALESCE(`wornlevel`, 0) > 0 OR COALESCE(`wornlevel2`, 0) > 0 OR
      COALESCE(`focuslevel`, 0) > 0 OR COALESCE(`focuslevel2`, 0) > 0
    )
);

UPDATE `items` i
LEFT JOIN `msr_recovery_sympathetic_spell_ids` proc_spell
  ON proc_spell.`id` = i.`proceffect`
LEFT JOIN `msr_recovery_sympathetic_spell_ids` worn_spell
  ON worn_spell.`id` = i.`worneffect`
LEFT JOIN `msr_recovery_sympathetic_spell_ids` focus_spell
  ON focus_spell.`id` = i.`focuseffect`
SET
  i.`proclevel` = CASE WHEN proc_spell.`id` IS NOT NULL THEN 0 ELSE i.`proclevel` END,
  i.`proclevel2` = CASE WHEN proc_spell.`id` IS NOT NULL THEN 0 ELSE i.`proclevel2` END,
  i.`wornlevel` = CASE WHEN worn_spell.`id` IS NOT NULL THEN 0 ELSE i.`wornlevel` END,
  i.`wornlevel2` = CASE WHEN worn_spell.`id` IS NOT NULL THEN 0 ELSE i.`wornlevel2` END,
  i.`focuslevel` = CASE WHEN focus_spell.`id` IS NOT NULL THEN 0 ELSE i.`focuslevel` END,
  i.`focuslevel2` = CASE WHEN focus_spell.`id` IS NOT NULL THEN 0 ELSE i.`focuslevel2` END
WHERE (
    proc_spell.`id` IS NOT NULL
    OR worn_spell.`id` IS NOT NULL
    OR focus_spell.`id` IS NOT NULL
  )
  AND (
    COALESCE(i.`proclevel`, 0) > 0 OR COALESCE(i.`proclevel2`, 0) > 0 OR
    COALESCE(i.`wornlevel`, 0) > 0 OR COALESCE(i.`wornlevel2`, 0) > 0 OR
    COALESCE(i.`focuslevel`, 0) > 0 OR COALESCE(i.`focuslevel2`, 0) > 0
  );

SET @msr_sympathetic_rows_changed := ROW_COUNT();

SET @msr_sympathetic_level_gated_rows_after := (
  SELECT COUNT(*)
  FROM `items`
  WHERE (
      `proceffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
      OR `worneffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
      OR `focuseffect` IN (SELECT `id` FROM `msr_recovery_sympathetic_spell_ids`)
    )
    AND (
      COALESCE(`proclevel`, 0) > 0 OR COALESCE(`proclevel2`, 0) > 0 OR
      COALESCE(`wornlevel`, 0) > 0 OR COALESCE(`wornlevel2`, 0) > 0 OR
      COALESCE(`focuslevel`, 0) > 0 OR COALESCE(`focuslevel2`, 0) > 0
    )
);

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '060_apply_sympathetic_level_gate_recovery.sql',
    CONCAT(
      'Removed proc/worn/focus level gates from Sympathetic item effects. Before=',
      @msr_sympathetic_level_gated_rows_before,
      ', changed=',
      @msr_sympathetic_rows_changed,
      ', after=',
      @msr_sympathetic_level_gated_rows_after,
      '. Required/recommended levels and Simple Ring of the Hero were intentionally not changed in this slice.'
    )
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);

DROP TEMPORARY TABLE IF EXISTS `msr_recovery_sympathetic_spell_ids`;
