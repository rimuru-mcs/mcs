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

-- PROMOTED TO SAFE MIGRATION IN SLICE V7:
--   - Enable bucket-backed progression max-level enforcement.
--   - Keep qglobal-backed progression cap enforcement disabled so data_buckets CharMaxLevel
--     remains the active cap source.
--
-- See:
--   database/recovery/migrations_safe/050_apply_bucket_progression_cap_recovery.sql
--   database/recovery/audits/11_progression_cap_recovery_audit.sql

-- Corpse-run recovery rationale:
--   Lost notes say "Fixed rules in DB to prevent corpse runs".
--   Code review of zone/attack.cpp and zone/corpse.cpp indicates the safe recovery posture is:
--     Character:LeaveCorpses = false
--     Character:LeaveNakedCorpses = true
--     Character:DeathItemLossLevel = 255
--   This preserves naked corpses for resurrection-style flow while preventing inventory/cash from
--   being moved onto corpses.

-- Progression max-level recovery rationale:
--   Lost notes say players could level past their progression max.
--   Audit 10 confirmed CharMaxLevel values are stored in data_buckets, not quest_globals.
--   Source code checks qglobal before bucket, so enabling both would risk bypassing bucket caps.
