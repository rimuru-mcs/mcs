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
-- Slice v6 adds a focused audit before promoting a migration:
--   database/recovery/audits/10_progression_cap_storage_audit.sql
--   database/recovery/migrations_pending/070_review_progression_cap_candidates.sql
--
-- Important code-path warning:
--   Character:PerCharacterQglobalMaxLevel is checked before Character:PerCharacterBucketMaxLevel.
--   Do not enable both blindly, or bucket-backed caps may be ignored.
