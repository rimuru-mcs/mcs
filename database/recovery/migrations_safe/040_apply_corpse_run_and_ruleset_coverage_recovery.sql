-- MSR Recovery Safe Migration 040
-- Applies the next low-risk DB rule recovery fixes supported by the lost 5/20-5/21 notes
-- and the Slice v4 audit output.
--
-- Promoted in Slice v5:
--   - Prevent item corpse runs while preserving naked corpses for resurrection flow.
--   - Propagate previously-safe Slice v4 rule fixes across any existing overriding rulesets.
--
-- Rationale:
--   - The restored DB had Character:LeaveCorpses=true and Character:LeaveNakedCorpses=true,
--     which allows item/cash corpse runs.
--   - EQEmu corpse code can keep naked corpses for rez while not moving player inventory/currency
--     when LeaveCorpses=false and LeaveNakedCorpses=true.
--   - Audit output also showed ruleset 10 overriding Combat:MinRangedAttackDist back to 25,
--     so existing override rows need coverage, not just default ruleset 1.
--
-- Intentionally NOT included here:
--   - Per-character progression max-level enforcement. The code path exists, but the exact intended
--     qglobal/data-bucket population strategy still needs a focused audit before enabling.
--   - Death experience loss changes. The lost notes only mention preventing corpse runs, not removing
--     death EXP loss.

SET @msr_leave_corpses_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'Character:LeaveCorpses'
);

SET @msr_leave_naked_corpses_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'Character:LeaveNakedCorpses'
);

SET @msr_death_item_loss_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'Character:DeathItemLossLevel'
);

SET @msr_min_ranged_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'Combat:MinRangedAttackDist'
);

SET @msr_tutorial_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'World:EnableTutorialButton'
);

SET @msr_implied_targeting_rows_before := (
  SELECT COUNT(*)
  FROM `rule_values`
  WHERE `rule_name` = 'Spells:UseSpellImpliedTargeting'
);

-- Ensure default ruleset has the corpse-run prevention rows.
INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Character:LeaveCorpses',
    'false',
    'MSR recovery Slice v5: disabled item/cash corpse runs while preserving naked corpse support.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: disabled item/cash corpse runs%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: disabled item/cash corpse runs while preserving naked corpse support.')
  END;

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Character:LeaveNakedCorpses',
    'true',
    'MSR recovery Slice v5: preserved naked corpses for resurrection flow without item corpse runs.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: preserved naked corpses%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: preserved naked corpses for resurrection flow without item corpse runs.')
  END;

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Character:DeathItemLossLevel',
    '255',
    'MSR recovery Slice v5: raised item-loss threshold as a belt-and-suspenders corpse-run prevention guard.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: raised item-loss threshold%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: raised item-loss threshold as a belt-and-suspenders corpse-run prevention guard.')
  END;

-- Propagate corpse-run prevention to any existing overriding ruleset rows.
UPDATE `rule_values`
SET
  `rule_value` = 'false',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: disabled item/cash corpse runs%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: disabled item/cash corpse runs while preserving naked corpse support.')
  END
WHERE `rule_name` = 'Character:LeaveCorpses';

UPDATE `rule_values`
SET
  `rule_value` = 'true',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: preserved naked corpses%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: preserved naked corpses for resurrection flow without item corpse runs.')
  END
WHERE `rule_name` = 'Character:LeaveNakedCorpses';

UPDATE `rule_values`
SET
  `rule_value` = '255',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: raised item-loss threshold%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: raised item-loss threshold as a belt-and-suspenders corpse-run prevention guard.')
  END
WHERE `rule_name` = 'Character:DeathItemLossLevel';

-- Propagate Slice v4 safe rule fixes to any existing overriding ruleset rows.
UPDATE `rule_values`
SET
  `rule_value` = '0',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: propagated ranged minimum distance%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: propagated ranged minimum distance recovery across existing ruleset overrides.')
  END
WHERE `rule_name` = 'Combat:MinRangedAttackDist';

UPDATE `rule_values`
SET
  `rule_value` = 'false',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: propagated tutorial disable%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: propagated tutorial disable across existing ruleset overrides.')
  END
WHERE `rule_name` = 'World:EnableTutorialButton';

UPDATE `rule_values`
SET
  `rule_value` = 'true',
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v5: propagated implied targeting%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v5: propagated implied targeting across existing ruleset overrides.')
  END
WHERE `rule_name` = 'Spells:UseSpellImpliedTargeting';

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '040_apply_corpse_run_and_ruleset_coverage_recovery.sql',
    CONCAT(
      'Applied corpse-run prevention and safe ruleset override coverage. Existing rows before update: LeaveCorpses=',
      @msr_leave_corpses_rows_before,
      ', LeaveNakedCorpses=',
      @msr_leave_naked_corpses_rows_before,
      ', DeathItemLossLevel=',
      @msr_death_item_loss_rows_before,
      ', MinRangedAttackDist=',
      @msr_min_ranged_rows_before,
      ', TutorialButton=',
      @msr_tutorial_rows_before,
      ', ImpliedTargeting=',
      @msr_implied_targeting_rows_before,
      '. Progression max-level rules remain pending focused audit.'
    )
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
