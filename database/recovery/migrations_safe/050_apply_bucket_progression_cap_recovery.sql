-- MSR Recovery Safe Migration 050
-- Enables bucket-backed per-character progression max-level enforcement.
--
-- Promoted in Slice v7 after Audit 10 showed:
--   - data_buckets contains CharMaxLevel rows.
--   - quest_globals contains no CharMaxLevel rows.
--   - CharMaxLevel bucket values are numeric and currently all 50 in the recovered DB.
--
-- Lost 5/21 notes mention:
--   "Fixed an issue that was allowing players to level past max level based off there progression"
--
-- Source-code truth:
--   Character:PerCharacterQglobalMaxLevel is checked first.
--   Character:PerCharacterBucketMaxLevel is checked second.
--   Enabling both can accidentally ignore bucket-backed caps.
--
-- Recovery posture:
--   - Enable bucket-backed cap enforcement.
--   - Disable qglobal-backed cap enforcement.
--   - Apply to all existing rule sets so alternate active rulesets do not bypass progression caps.
--
-- Intentionally NOT included:
--   - Character:MaxLevel / Character:MaxExpLevel changes.
--   - Character:KeepLevelOverMax changes.
--   - Manual edits to existing over-cap characters. Audit output should continue to surface them.

SET @msr_ruleset_count := (
  SELECT COUNT(*)
  FROM `rule_sets`
);

SET @msr_bucket_cap_rows := (
  SELECT COUNT(*)
  FROM `data_buckets`
  WHERE `key` = 'CharMaxLevel'
);

SET @msr_qglobal_cap_rows := (
  SELECT COUNT(*)
  FROM `quest_globals`
  WHERE `name` = 'CharMaxLevel'
);

SET @msr_non_numeric_bucket_cap_rows := (
  SELECT COUNT(*)
  FROM `data_buckets`
  WHERE `key` = 'CharMaxLevel'
    AND NOT (`value` REGEXP '^[0-9]+$')
);

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
SELECT
  `ruleset_id`,
  'Character:PerCharacterBucketMaxLevel',
  'true',
  'MSR recovery Slice v7: enabled bucket-backed CharMaxLevel progression cap enforcement after audit confirmed data_buckets as the active cap source.'
FROM `rule_sets`
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v7: enabled bucket-backed CharMaxLevel progression cap enforcement%'
      THEN `notes`
    ELSE CONCAT(
      COALESCE(`notes`, ''),
      ' | MSR recovery Slice v7: enabled bucket-backed CharMaxLevel progression cap enforcement after audit confirmed data_buckets as the active cap source.'
    )
  END;

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
SELECT
  `ruleset_id`,
  'Character:PerCharacterQglobalMaxLevel',
  'false',
  'MSR recovery Slice v7: disabled qglobal-backed CharMaxLevel enforcement so bucket-backed caps are not bypassed.'
FROM `rule_sets`
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v7: disabled qglobal-backed CharMaxLevel enforcement%'
      THEN `notes`
    ELSE CONCAT(
      COALESCE(`notes`, ''),
      ' | MSR recovery Slice v7: disabled qglobal-backed CharMaxLevel enforcement so bucket-backed caps are not bypassed.'
    )
  END;

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '050_apply_bucket_progression_cap_recovery.sql',
    CONCAT(
      'Enabled Character:PerCharacterBucketMaxLevel=true and Character:PerCharacterQglobalMaxLevel=false for ',
      @msr_ruleset_count,
      ' ruleset(s). Audit-before-apply saw ',
      @msr_bucket_cap_rows,
      ' data_buckets CharMaxLevel row(s), ',
      @msr_qglobal_cap_rows,
      ' quest_globals CharMaxLevel row(s), and ',
      @msr_non_numeric_bucket_cap_rows,
      ' non-numeric bucket cap row(s). Character:MaxLevel, Character:MaxExpLevel, KeepLevelOverMax, and existing character levels were intentionally not changed.'
    )
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
