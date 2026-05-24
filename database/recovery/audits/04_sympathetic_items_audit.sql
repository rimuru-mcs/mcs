-- MSR Recovery Audit 04: sympathetic proc/item state
-- The lost notes mention sympathetic items proccing at all levels and Sympathetic Strike I on Simple Ring of the Hero.

SELECT 'audit' AS section, '04_sympathetic_items' AS audit_name, NOW() AS audited_at;

SELECT
  id,
  name,
  goodEffect,
  targettype,
  effectid1, effect_base_value1,
  effectid2, effect_base_value2,
  effectid3, effect_base_value3,
  classes1, classes2, classes3, classes4, classes5, classes6, classes7,
  classes8, classes9, classes10, classes11, classes12, classes13
FROM spells_new
WHERE name LIKE '%Sympathetic%'
   OR name LIKE '%Sympathy%'
   OR name LIKE '%Strike I%'
ORDER BY id;

SELECT
  id,
  Name,
  proceffect,
  proctype,
  proclevel,
  proclevel2,
  worneffect,
  wornlevel,
  wornlevel2,
  focuseffect,
  focuslevel,
  focuslevel2,
  clickeffect,
  clicklevel,
  clicklevel2,
  reqlevel,
  reclevel,
  classes,
  slots
FROM items
WHERE Name LIKE '%Simple Ring of the Hero%'
   OR procname LIKE '%Sympathetic%'
   OR wornname LIKE '%Sympathetic%'
   OR focusname LIKE '%Sympathetic%'
   OR clickname LIKE '%Sympathetic%'
   OR proceffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
   OR worneffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
   OR focuseffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
ORDER BY id;

SELECT
  COUNT(*) AS sympathetic_items_with_level_gates
FROM items
WHERE (
    proceffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
    OR worneffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
    OR focuseffect IN (SELECT id FROM spells_new WHERE name LIKE '%Sympathetic%')
  )
  AND (
    COALESCE(proclevel, 0) > 0 OR COALESCE(proclevel2, 0) > 0 OR
    COALESCE(wornlevel, 0) > 0 OR COALESCE(wornlevel2, 0) > 0 OR
    COALESCE(focuslevel, 0) > 0 OR COALESCE(focuslevel2, 0) > 0
  );
