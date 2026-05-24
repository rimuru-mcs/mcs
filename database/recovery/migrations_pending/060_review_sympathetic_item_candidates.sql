-- MSR Recovery Pending Migration 060: sympathetic item candidates
-- DO NOT AUTO-RUN. Requires exact spell ID confirmation.

-- Lost notes mention sympathetic items should proc at all levels, not just level 70.
-- Candidate after audit 04 confirms affected items:
-- UPDATE items
-- SET proclevel = 0, proclevel2 = 0
-- WHERE proceffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%');

-- Some sympathetic behavior may use worn/focus effects instead of proceffect:
-- UPDATE items
-- SET wornlevel = 0, wornlevel2 = 0
-- WHERE worneffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%');
-- UPDATE items
-- SET focuslevel = 0, focuslevel2 = 0
-- WHERE focuseffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%');

-- Simple Ring of the Hero gets Sympathetic Strike I.
-- Candidate only after exact spell ID is confirmed from audit 04:
-- UPDATE items
-- SET proceffect = <Sympathetic Strike I spell id>, proctype = <confirmed proc type>, proclevel = 0, proclevel2 = 0
-- WHERE Name = 'Simple Ring of the Hero';
