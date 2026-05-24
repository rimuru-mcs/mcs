-- MSR Recovery Audit 09: corpse-run prevention and ruleset override coverage checks

SELECT 'audit' AS section, '09_corpse_and_ruleset_coverage' AS audit_name, NOW() AS audited_at;

SELECT
  `ruleset_id`,
  `name`
FROM `rule_sets`
ORDER BY `ruleset_id`;

SELECT
  `ruleset_id`,
  MAX(CASE WHEN `rule_name` = 'Character:LeaveCorpses' THEN `rule_value` END) AS leave_corpses,
  MAX(CASE WHEN `rule_name` = 'Character:LeaveNakedCorpses' THEN `rule_value` END) AS leave_naked_corpses,
  MAX(CASE WHEN `rule_name` = 'Character:DeathItemLossLevel' THEN `rule_value` END) AS death_item_loss_level,
  MAX(CASE WHEN `rule_name` = 'Combat:MinRangedAttackDist' THEN `rule_value` END) AS min_ranged_attack_dist,
  MAX(CASE WHEN `rule_name` = 'World:EnableTutorialButton' THEN `rule_value` END) AS tutorial_button,
  MAX(CASE WHEN `rule_name` = 'Spells:UseSpellImpliedTargeting' THEN `rule_value` END) AS implied_targeting,
  MAX(CASE WHEN `rule_name` = 'Character:PerCharacterBucketMaxLevel' THEN `rule_value` END) AS per_character_bucket_max_level,
  MAX(CASE WHEN `rule_name` = 'Character:PerCharacterQglobalMaxLevel' THEN `rule_value` END) AS per_character_qglobal_max_level,
  MAX(CASE WHEN `rule_name` = 'Character:MaxLevel' THEN `rule_value` END) AS max_level
FROM `rule_values`
WHERE `rule_name` IN (
  'Character:LeaveCorpses',
  'Character:LeaveNakedCorpses',
  'Character:DeathItemLossLevel',
  'Combat:MinRangedAttackDist',
  'World:EnableTutorialButton',
  'Spells:UseSpellImpliedTargeting',
  'Character:PerCharacterBucketMaxLevel',
  'Character:PerCharacterQglobalMaxLevel',
  'Character:MaxLevel'
)
GROUP BY `ruleset_id`
ORDER BY `ruleset_id`;

SELECT
  SUM(CASE WHEN `rule_name` = 'Character:LeaveCorpses' AND `rule_value` = 'false' THEN 1 ELSE 0 END) AS leave_corpses_false_rows,
  SUM(CASE WHEN `rule_name` = 'Character:LeaveNakedCorpses' AND `rule_value` = 'true' THEN 1 ELSE 0 END) AS leave_naked_corpses_true_rows,
  SUM(CASE WHEN `rule_name` = 'Character:DeathItemLossLevel' AND `rule_value` = '255' THEN 1 ELSE 0 END) AS death_item_loss_255_rows,
  SUM(CASE WHEN `rule_name` = 'Combat:MinRangedAttackDist' AND `rule_value` = '0' THEN 1 ELSE 0 END) AS min_ranged_zero_rows,
  SUM(CASE WHEN `rule_name` = 'World:EnableTutorialButton' AND `rule_value` = 'false' THEN 1 ELSE 0 END) AS tutorial_disabled_rows,
  SUM(CASE WHEN `rule_name` = 'Spells:UseSpellImpliedTargeting' AND `rule_value` = 'true' THEN 1 ELSE 0 END) AS implied_targeting_enabled_rows
FROM `rule_values`
WHERE `rule_name` IN (
  'Character:LeaveCorpses',
  'Character:LeaveNakedCorpses',
  'Character:DeathItemLossLevel',
  'Combat:MinRangedAttackDist',
  'World:EnableTutorialButton',
  'Spells:UseSpellImpliedTargeting'
);

SELECT
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` IN (
  'Character:LeaveCorpses',
  'Character:LeaveNakedCorpses',
  'Character:DeathItemLossLevel',
  'Combat:MinRangedAttackDist',
  'World:EnableTutorialButton',
  'Spells:UseSpellImpliedTargeting'
)
ORDER BY `rule_name`, `ruleset_id`;

SELECT
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` IN (
  '020_apply_safe_rule_recovery_defaults.sql',
  '030_apply_syncrosatchel_price_recovery.sql',
  '040_apply_corpse_run_and_ruleset_coverage_recovery.sql'
)
ORDER BY `migration_name`;
