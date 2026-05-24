-- MSR Recovery Pending Migration 020: rule recovery candidates
-- DO NOT AUTO-RUN. Review audit output first.
-- These statements are candidate changes inferred from the lost notes.

-- TutorialB option removed from character creation UI/server entry path.
-- Candidate:
-- UPDATE rule_values SET rule_value = 'false'
-- WHERE ruleset_id = 1 AND rule_name = 'World:EnableTutorialButton';

-- Implied healing/target's-target behavior.
-- Candidate:
-- UPDATE rule_values SET rule_value = 'true'
-- WHERE ruleset_id = 1 AND rule_name = 'Spells:UseSpellImpliedTargeting';

-- Ranged attacks usable at melee distance.
-- Candidate:
-- UPDATE rule_values SET rule_value = '0'
-- WHERE ruleset_id = 1 AND rule_name = 'Combat:MinRangedAttackDist';

-- Prevent corpse runs. This is dangerous because it changes death behavior.
-- Candidate set A: no item-loss corpse runs, but corpses may still exist for resurrection.
-- UPDATE rule_values SET rule_value = 'false'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:LeaveCorpses';
-- UPDATE rule_values SET rule_value = 'false'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:LeaveNakedCorpses';
-- UPDATE rule_values SET rule_value = '0'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:DeathItemLossLevel';

-- Progression max-level enforcement needs code/data confirmation before SQL changes.
-- Candidate only if CharMaxLevel bucket/qglobal code path is active:
-- UPDATE rule_values SET rule_value = 'true'
-- WHERE ruleset_id = 1 AND rule_name IN ('Character:PerCharacterBucketMaxLevel', 'Character:PerCharacterQglobalMaxLevel');
