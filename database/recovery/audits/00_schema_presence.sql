-- MSR Recovery Audit 00: schema/table presence
-- Run this first to confirm the restored database matches the expected EQEmu/MSR layout.

SELECT 'audit' AS section, '00_schema_presence' AS audit_name, DATABASE() AS database_name, NOW() AS audited_at;

SELECT
  t.table_name,
  t.table_rows,
  t.engine,
  t.table_collation
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name IN (
    'rule_values',
    'variables',
    'spells_new',
    'items',
    'merchantlist',
    'npc_types',
    'doors',
    'zone',
    'zone_points',
    'lootdrop_entries',
    'loottable_entries'
  )
ORDER BY t.table_name;

SELECT
  'rule_values' AS table_name,
  c.column_name,
  c.column_type,
  c.is_nullable,
  c.column_default
FROM information_schema.columns c
WHERE c.table_schema = DATABASE()
  AND c.table_name = 'rule_values'
ORDER BY c.ordinal_position;

SELECT
  'items' AS table_name,
  c.column_name,
  c.column_type
FROM information_schema.columns c
WHERE c.table_schema = DATABASE()
  AND c.table_name = 'items'
  AND c.column_name IN (
    'id', 'Name', 'price', 'classes', 'slots', 'bagslots', 'bagtype', 'bagwr',
    'attuneable', 'artifactflag', 'nodrop', 'proceffect', 'proctype', 'proclevel',
    'proclevel2', 'worneffect', 'wornlevel', 'wornlevel2', 'focuseffect',
    'focuslevel', 'focuslevel2', 'minstatus', 'loregroup'
  )
ORDER BY c.ordinal_position;
