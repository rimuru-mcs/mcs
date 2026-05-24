-- MSR Recovery Safe Migration 020
-- Applies the lowest-risk DB rule fixes that are directly supported by the lost 5/20-5/21 notes
-- and confirmed by audit output as currently unset in the restored baseline.
--
-- Promoted in Slice v4:
--   - Disable tutorial button/server entry route.
--   - Enable implied spell targeting.
--   - Allow ranged attacks at melee distance by setting minimum ranged attack distance to 0.
--
-- Intentionally NOT included here:
--   - Corpse-run/death-item-loss rule changes. Those affect resurrection/death flow and remain pending.
--   - Per-character progression max-level enforcement. That depends on code/data-bucket path confirmation.

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'World:EnableTutorialButton',
    'false',
    'MSR recovery Slice v4: disabled tutorial button per lost 5/20 recovery notes.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v4: disabled tutorial button%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v4: disabled tutorial button per lost 5/20 recovery notes.')
  END;

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Spells:UseSpellImpliedTargeting',
    'true',
    'MSR recovery Slice v4: enabled implied targeting per lost 5/21 recovery notes.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v4: enabled implied targeting%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v4: enabled implied targeting per lost 5/21 recovery notes.')
  END;

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Combat:MinRangedAttackDist',
    '0',
    'MSR recovery Slice v4: set ranged minimum distance to zero per lost 5/20 recovery notes.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v4: set ranged minimum distance%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v4: set ranged minimum distance to zero per lost 5/20 recovery notes.')
  END;

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '020_apply_safe_rule_recovery_defaults.sql',
    'Applied safe rule recovery defaults: tutorial disabled, implied targeting enabled, minimum ranged attack distance set to 0. Corpse/progression rules intentionally left pending.'
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
