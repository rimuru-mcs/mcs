-- MSR Recovery Audit 01: rules and server-default candidates
-- Covers corpse-run prevention, tutorial button removal, implied healing, ranged attack distance,
-- max-level/progression gates, and the permanent server buff toggle.

SELECT 'audit' AS section, '01_rules_and_server_defaults' AS audit_name, NOW() AS audited_at;

SELECT
  ruleset_id,
  rule_name,
  rule_value,
  notes
FROM rule_values
WHERE rule_name IN (
  'Custom:PermanentServerBuffsEnabled',
  'World:EnableTutorialButton',
  'World:TutorialZoneID',
  'World:MaxLevelForTutorial',
  'Spells:UseSpellImpliedTargeting',
  'Spells:TargetsTargetRequiresCombatRange',
  'Combat:MinRangedAttackDist',
  'Character:LeaveCorpses',
  'Character:LeaveNakedCorpses',
  'Character:DeathItemLossLevel',
  'Character:DeathExpLossLevel',
  'Character:DeathExpLossMaxLevel',
  'Character:MaxLevel',
  'Character:PerCharacterBucketMaxLevel',
  'Character:PerCharacterQglobalMaxLevel',
  'Character:SkillCapMaxLevel',
  'Zone:GraveyardTimeMS',
  'Zone:EnableShadowrest'
)
ORDER BY ruleset_id, rule_name;

SELECT
  ruleset_id,
  rule_name,
  rule_value,
  notes
FROM rule_values
WHERE rule_name LIKE 'Custom:%'
   OR rule_name LIKE '%Tutorial%'
   OR rule_name LIKE '%Corpse%'
   OR rule_name LIKE '%Graveyard%'
   OR rule_name LIKE '%MaxLevel%'
ORDER BY ruleset_id, rule_name;
