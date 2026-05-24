-- MSR Recovery Audit 08: safe Slice v4 rule and Syncrosatchel recovery checks

SELECT 'audit' AS section, '08_safe_rule_and_syncrosatchel_recovery' AS audit_name, NOW() AS audited_at;

SELECT
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `ruleset_id` = 1
  AND `rule_name` IN (
    'World:EnableTutorialButton',
    'Spells:UseSpellImpliedTargeting',
    'Combat:MinRangedAttackDist',
    'Character:DeathItemLossLevel',
    'Character:LeaveCorpses',
    'Character:LeaveNakedCorpses',
    'Character:PerCharacterBucketMaxLevel',
    'Character:PerCharacterQglobalMaxLevel',
    'Custom:PermanentServerBuffsEnabled'
  )
ORDER BY `rule_name`;

SELECT
  `id`,
  `Name`,
  `price`,
  `bagslots`,
  `bagtype`,
  `itemclass`,
  `classes`,
  `loregroup`
FROM `items`
WHERE `Name` LIKE '%Syncrosatchel%'
ORDER BY `id`;

SELECT
  COUNT(*) AS expanded_syncrosatchel_count,
  SUM(CASE WHEN `price` = 5000000 THEN 1 ELSE 0 END) AS expanded_syncrosatchels_at_5000_plat,
  MIN(`price`) AS min_expanded_price,
  MAX(`price`) AS max_expanded_price
FROM `items`
WHERE `Name` LIKE 'Expanded %Syncrosatchel%';

SELECT
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` IN (
  '020_apply_safe_rule_recovery_defaults.sql',
  '030_apply_syncrosatchel_price_recovery.sql'
)
ORDER BY `migration_name`;
