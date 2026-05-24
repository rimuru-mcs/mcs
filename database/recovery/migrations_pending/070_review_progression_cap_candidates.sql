-- MSR Recovery Pending Migration 070: progression max-level candidates
-- DO NOT AUTO-RUN. Requires audit 10 output first.

-- Lost notes mention:
--   Fixed an issue that was allowing players to level past max level based off their progression.

-- Source-code truth:
--   zone/client.cpp and zone/client_packet.cpp choose one per-character max-level source:
--     if Character:PerCharacterQglobalMaxLevel is true, use quest_globals name='CharMaxLevel'
--     else if Character:PerCharacterBucketMaxLevel is true, use data_buckets key='CharMaxLevel'
--   Because qglobal is checked first, enabling both can accidentally ignore data bucket caps.

-- Historical EQEmu changelog in this repo says data bucket level caps use:
--   data_buckets.character_id + key='CharMaxLevel'
--   Character:PerCharacterBucketMaxLevel rule

-- PROMOTED TO SAFE MIGRATION IN SLICE V7:
--   Audit 10 confirmed CharMaxLevel caps are present in data_buckets and absent from quest_globals.
--   Slice v7 promotes Candidate A:
--     Character:PerCharacterBucketMaxLevel  = true
--     Character:PerCharacterQglobalMaxLevel = false
--   across all existing rule sets.
--
-- See:
--   database/recovery/migrations_safe/050_apply_bucket_progression_cap_recovery.sql
--   database/recovery/audits/11_progression_cap_recovery_audit.sql

-- Candidate B remains rejected for this recovered baseline:
--   qglobal-backed enforcement is not enabled because audit 10 found no CharMaxLevel qglobals.

-- Do not set Character:MaxLevel here. The DB currently has ruleset-specific max-level rows,
-- and progression enforcement should use the per-character bucket cap source confirmed by audit.
