-- 19_defiant_spawn_source_audit.sql
-- MSR Recovery Slice v15.1
-- Purpose:
--   Audit Defiant item spawn/source paths without assuming newer EQEmu
--   lootdrop_entries columns such as minlevel/maxlevel/multiplier.
--
-- Safety:
--   Read-only audit. No UPDATE/DELETE/INSERT statements.

SELECT
  'defiant_audit_note' AS section,
  'This audit intentionally uses conservative schema columns so it works on the restored MSR baseline.' AS note;

SELECT
  'lootdrop_entries_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'lootdrop_entries'
ORDER BY ORDINAL_POSITION;

SELECT
  'loottable_entries_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'loottable_entries'
ORDER BY ORDINAL_POSITION;

SELECT
  'merchantlist_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'merchantlist'
ORDER BY ORDINAL_POSITION;

SELECT
  'defiant_item_count' AS section,
  COUNT(*) AS count_value
FROM items
WHERE Name LIKE '%Defiant%';

SELECT
  'defiant_items_sample' AS section,
  id,
  Name,
  itemtype,
  classes,
  races,
  slots,
  reqlevel,
  reclevel,
  nodrop,
  norent
FROM items
WHERE Name LIKE '%Defiant%'
ORDER BY id
LIMIT 300;

SELECT
  'defiant_lootdrop_entry_count' AS section,
  COUNT(*) AS count_value
FROM lootdrop_entries lde
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_lootdrop_entries' AS section,
  lde.lootdrop_id,
  lde.item_id,
  i.Name,
  lde.item_charges,
  lde.equip_item,
  lde.chance,
  lde.disabled_chance
FROM lootdrop_entries lde
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%'
ORDER BY lde.lootdrop_id, lde.item_id
LIMIT 300;

SELECT
  'defiant_loottable_link_count' AS section,
  COUNT(*) AS count_value
FROM loottable_entries lte
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_loottable_links' AS section,
  lte.loottable_id,
  lte.lootdrop_id,
  lde.item_id,
  i.Name
FROM loottable_entries lte
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%'
ORDER BY lte.loottable_id, lte.lootdrop_id, lde.item_id
LIMIT 300;

SELECT
  'defiant_npc_source_count' AS section,
  COUNT(DISTINCT nt.id) AS count_value
FROM npc_types nt
JOIN loottable_entries lte ON lte.loottable_id = nt.loottable_id
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_npc_sources_sample' AS section,
  nt.id AS npc_type_id,
  nt.name AS npc_name,
  nt.loottable_id,
  lte.lootdrop_id,
  lde.item_id,
  i.Name AS item_name
FROM npc_types nt
JOIN loottable_entries lte ON lte.loottable_id = nt.loottable_id
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%'
ORDER BY nt.id, lte.lootdrop_id, lde.item_id
LIMIT 300;

SELECT
  'defiant_merchant_entry_count' AS section,
  COUNT(*) AS count_value
FROM merchantlist ml
JOIN items i ON i.id = ml.item
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_merchant_entries' AS section,
  ml.merchantid,
  ml.slot,
  ml.item,
  i.Name
FROM merchantlist ml
JOIN items i ON i.id = ml.item
WHERE i.Name LIKE '%Defiant%'
ORDER BY ml.merchantid, ml.slot, ml.item
LIMIT 300;
