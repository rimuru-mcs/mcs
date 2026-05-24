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

-- PROMOTED TO SAFE MIGRATION IN SLICE V5:
--   - Propagate safe Slice v4 rules across existing overriding ruleset rows.
--   - Prevent item/cash corpse runs while preserving naked corpse support for resurrection.
--
-- See:
--   database/recovery/migrations_safe/040_apply_corpse_run_and_ruleset_coverage_recovery.sql
--   database/recovery/audits/09_corpse_and_ruleset_coverage_audit.sql

-- Corpse-run recovery rationale:
--   Lost notes say "Fixed rules in DB to prevent corpse runs".
--   Code review of zone/attack.cpp and zone/corpse.cpp indicates the safe recovery posture is:
--     Character:LeaveCorpses = false
--     Character:LeaveNakedCorpses = true
--     Character:DeathItemLossLevel = 255
--   This preserves naked corpses for resurrection-style flow while preventing inventory/cash from
--   being moved onto corpses.

-- Progression max-level enforcement remains pending.
-- The code path exists:
--   - Character:PerCharacterQglobalMaxLevel reads qglobal CharMaxLevel.
--   - Character:PerCharacterBucketMaxLevel reads data bucket CharMaxLevel.
--   - Missing/empty CharMaxLevel returns 0, which behaves as no per-character cap.
--
-- Candidate only after focused audit confirms intended CharMaxLevel storage:
-- UPDATE rule_values SET rule_value = 'true'
-- WHERE ruleset_id = 1 AND rule_name IN ('Character:PerCharacterBucketMaxLevel', 'Character:PerCharacterQglobalMaxLevel');
