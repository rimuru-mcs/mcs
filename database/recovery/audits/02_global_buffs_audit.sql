-- MSR Recovery Audit 02: global buff spell and rule state
-- The lost notes mention 44000-44007, Echo of Luck, and later Echo of Power consolidation.

SELECT 'audit' AS section, '02_global_buffs' AS audit_name, NOW() AS audited_at;

SELECT
  id,
  name,
  goodEffect,
  targettype,
  buffdurationformula,
  buffduration,
  cast_time,
  recovery_time,
  recast_time,
  mana,
  effectid1, effect_base_value1, effect_limit_value1, max1,
  effectid2, effect_base_value2, effect_limit_value2, max2,
  effectid3, effect_base_value3, effect_limit_value3, max3,
  effectid4, effect_base_value4, effect_limit_value4, max4,
  classes1, classes2, classes3, classes4, classes5, classes6, classes7,
  classes8, classes9, classes10, classes11, classes12, classes13
FROM spells_new
WHERE id BETWEEN 44000 AND 44007
   OR name IN (
      'Echo of Experience', 'Echo of Armor', 'Echo of Statistics', 'Echo of Speed',
      'Echo of Mana', 'Echo of Haste', 'Echo of Health', 'Echo of Luck', 'Echo of Power'
   )
ORDER BY id;

SELECT
  ruleset_id,
  rule_name,
  rule_value,
  notes
FROM rule_values
WHERE rule_name = 'Custom:PermanentServerBuffsEnabled'
   OR rule_name LIKE '%Buff%'
   OR rule_name LIKE '%buff%'
ORDER BY ruleset_id, rule_name;
