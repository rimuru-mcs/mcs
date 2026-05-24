-- MSR Recovery Pending Migration 030: global buff candidates
-- DO NOT AUTO-RUN. Requires spell/client-file/server-code alignment.

-- Lost notes mention:
-- 44000 Echo of Experience
-- 44001 Echo of Armor, later merged into Echo of Power
-- 44002 Echo of Statistics
-- 44003 Echo of Speed
-- 44004 Echo of Mana
-- 44005 Echo of Haste
-- 44006 Echo of Health
-- 44007 Echo of Luck
-- 5/23 then reduced global buffs to 4 and combined others into Echo of Power.

-- Candidate toggle after code and spell rows are verified:
-- UPDATE rule_values
-- SET rule_value = 'true'
-- WHERE ruleset_id = 1 AND rule_name = 'Custom:PermanentServerBuffsEnabled';

-- Candidate spell rename only after client spells_us.txt and server spells_new agree:
-- UPDATE spells_new
-- SET name = 'Echo of Power'
-- WHERE id = 44001 AND name IN ('Echo of Armor', 'Echo of Power');

-- Candidate song-window visibility/display fields must be derived from the 5/23 spell file
-- and compared against spells_new before being promoted. Do not guess them here.
