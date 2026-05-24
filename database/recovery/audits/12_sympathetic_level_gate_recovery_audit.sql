-- MSR Recovery Audit 12: Sympathetic item level gate recovery verification

SELECT 'audit' AS section, '12_sympathetic_level_gate_recovery' AS audit_name, NOW() AS audited_at;

SELECT
  COUNT(*) AS sympathetic_items_with_level_gates_after
FROM `items`
WHERE (
    `proceffect` IN (SELECT `id` FROM `spells_new` WHERE `name` LIKE '%Sympathetic%')
    OR `worneffect` IN (SELECT `id` FROM `spells_new` WHERE `name` LIKE '%Sympathetic%')
    OR `focuseffect` IN (SELECT `id` FROM `spells_new` WHERE `name` LIKE '%Sympathetic%')
  )
  AND (
    COALESCE(`proclevel`, 0) > 0 OR COALESCE(`proclevel2`, 0) > 0 OR
    COALESCE(`wornlevel`, 0) > 0 OR COALESCE(`wornlevel2`, 0) > 0 OR
    COALESCE(`focuslevel`, 0) > 0 OR COALESCE(`focuslevel2`, 0) > 0
  );

SELECT
  i.`id`,
  i.`Name`,
  i.`proceffect`,
  proc_spell.`name` AS proc_spell_name,
  i.`proclevel`,
  i.`proclevel2`,
  i.`worneffect`,
  worn_spell.`name` AS worn_spell_name,
  i.`wornlevel`,
  i.`wornlevel2`,
  i.`focuseffect`,
  focus_spell.`name` AS focus_spell_name,
  i.`focuslevel`,
  i.`focuslevel2`,
  i.`reqlevel`,
  i.`reclevel`,
  i.`classes`,
  i.`slots`
FROM `items` i
LEFT JOIN `spells_new` proc_spell
  ON proc_spell.`id` = i.`proceffect`
LEFT JOIN `spells_new` worn_spell
  ON worn_spell.`id` = i.`worneffect`
LEFT JOIN `spells_new` focus_spell
  ON focus_spell.`id` = i.`focuseffect`
WHERE proc_spell.`name` LIKE '%Sympathetic%'
   OR worn_spell.`name` LIKE '%Sympathetic%'
   OR focus_spell.`name` LIKE '%Sympathetic%'
ORDER BY i.`id`
LIMIT 150;

SELECT
  i.`id`,
  i.`Name`,
  i.`proceffect`,
  proc_spell.`name` AS proc_spell_name,
  i.`proctype`,
  i.`proclevel`,
  i.`proclevel2`,
  i.`worneffect`,
  worn_spell.`name` AS worn_spell_name,
  i.`wornlevel`,
  i.`wornlevel2`,
  i.`focuseffect`,
  focus_spell.`name` AS focus_spell_name,
  i.`focuslevel`,
  i.`focuslevel2`,
  i.`reqlevel`,
  i.`reclevel`,
  i.`classes`,
  i.`slots`
FROM `items` i
LEFT JOIN `spells_new` proc_spell
  ON proc_spell.`id` = i.`proceffect`
LEFT JOIN `spells_new` worn_spell
  ON worn_spell.`id` = i.`worneffect`
LEFT JOIN `spells_new` focus_spell
  ON focus_spell.`id` = i.`focuseffect`
WHERE i.`Name` LIKE '%Simple Ring of the Hero%'
ORDER BY i.`id`;

SELECT
  `migration_name`,
  `applied_at`,
  `applied_by`,
  `notes`
FROM `msr_recovery_migration_log`
WHERE `migration_name` = '060_apply_sympathetic_level_gate_recovery.sql';
