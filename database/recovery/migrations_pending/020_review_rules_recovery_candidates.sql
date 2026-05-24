-- MSR Recovery Pending Migration 020: rule recovery candidates
-- DO NOT AUTO-RUN. Review audit output first.
-- These statements are candidate changes inferred from the lost notes.

-- PROMOTED TO SAFE MIGRATION IN SLICE V4:
--   - World:EnableTutorialButton = false
--   - Spells:UseSpellImpliedTargeting = true
--   - Combat:MinRangedAttackDist = 0
--
-- See:
--   database/recovery/migrations_safe/020_apply_safe_rule_recovery_defaults.sql

-- Corpse-run/death behavior remains pending.
-- Lost notes say "Fixed rules in DB to prevent corpse runs", but the exact intended
-- resurrection/corpse behavior must be confirmed before changing death rules.
--
-- Candidate set A: no item-loss corpse runs, but may alter resurrection/corpse behavior.
-- DO NOT PROMOTE until tested on the dev server:
-- UPDATE rule_values SET rule_value = 'false'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:LeaveCorpses';
-- UPDATE rule_values SET rule_value = 'false'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:LeaveNakedCorpses';
-- UPDATE rule_values SET rule_value = '0'
-- WHERE ruleset_id = 1 AND rule_name = 'Character:DeathItemLossLevel';

-- Progression max-level enforcement remains pending.
-- Candidate only if the CharMaxLevel bucket/qglobal code path is confirmed active:
-- UPDATE rule_values SET rule_value = 'true'
-- WHERE ruleset_id = 1 AND rule_name IN ('Character:PerCharacterBucketMaxLevel', 'Character:PerCharacterQglobalMaxLevel');
