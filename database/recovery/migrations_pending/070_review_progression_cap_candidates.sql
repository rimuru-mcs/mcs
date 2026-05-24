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

-- Candidate A: enable bucket-backed progression cap enforcement only.
-- Promote only if audit 10 shows CharMaxLevel caps are present in data_buckets and sane.
-- UPDATE `rule_values`
-- SET `rule_value` = 'true'
-- WHERE `ruleset_id` = 1
--   AND `rule_name` = 'Character:PerCharacterBucketMaxLevel';
--
-- UPDATE `rule_values`
-- SET `rule_value` = 'false'
-- WHERE `ruleset_id` = 1
--   AND `rule_name` = 'Character:PerCharacterQglobalMaxLevel';

-- Candidate B: enable qglobal-backed progression cap enforcement only.
-- Promote only if audit 10 shows CharMaxLevel caps are present in quest_globals and sane.
-- UPDATE `rule_values`
-- SET `rule_value` = 'false'
-- WHERE `ruleset_id` = 1
--   AND `rule_name` = 'Character:PerCharacterBucketMaxLevel';
--
-- UPDATE `rule_values`
-- SET `rule_value` = 'true'
-- WHERE `ruleset_id` = 1
--   AND `rule_name` = 'Character:PerCharacterQglobalMaxLevel';

-- Do not set Character:MaxLevel here. The DB currently has ruleset-specific max-level rows,
-- and progression enforcement should use the per-character cap source after audit confirmation.
