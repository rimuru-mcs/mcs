-- MSR Recovery Slice v15
-- Audit where Defiant-named items can still enter the world.
-- Read-only. Does not mutate database state.

SELECT
  'audit' AS section,
  '19_defiant_spawn_source' AS audit_name,
  NOW() AS audited_at;

-- Overall item count for Defiant-named rows.
SELECT
  'defiant_item_inventory' AS section,
  COUNT(*) AS defiant_item_count
FROM items
WHERE Name LIKE '%Defiant%';

-- Defiant package/container-ish entries are especially suspicious because they can unpack into gear.
SELECT
  'defiant_package_candidates' AS section,
  id,
  Name,
  itemclass,
  bagslots,
  bagtype,
  price,
  nodrop,
  attuneable,
  reqlevel,
  reclevel
FROM items
WHERE Name LIKE '%Defiant%'
  AND (
    Name LIKE '%Package%'
    OR Name LIKE '%Bundle%'
    OR itemclass <> 0
    OR bagslots > 0
  )
ORDER BY id
LIMIT 200;

-- Defiant items directly referenced by lootdrop entries.
SELECT
  'defiant_lootdrop_summary' AS section,
  COUNT(*) AS lootdrop_entry_rows,
  COUNT(DISTINCT lde.lootdrop_id) AS lootdrop_ids,
  COUNT(DISTINCT lde.item_id) AS distinct_defiant_items
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
  lde.disabled_chance,
  lde.minlevel,
  lde.maxlevel,
  lde.multiplier
FROM lootdrop_entries lde
JOIN items i ON i.id = lde.item_id
WHERE i.Name LIKE '%Defiant%'
ORDER BY lde.lootdrop_id, lde.item_id
LIMIT 300;

-- Trace Defiant lootdrop entries through loottables into NPCs.
SELECT
  'defiant_npc_loot_sources_summary' AS section,
  COUNT(*) AS npc_source_rows,
  COUNT(DISTINCT nt.id) AS npc_type_count,
  COUNT(DISTINCT nt.loottable_id) AS loottable_count,
  COUNT(DISTINCT lte.lootdrop_id) AS lootdrop_count
FROM lootdrop_entries lde
JOIN items i ON i.id = lde.item_id
JOIN loottable_entries lte ON lte.lootdrop_id = lde.lootdrop_id
JOIN npc_types nt ON nt.loottable_id = lte.loottable_id
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_npc_loot_sources' AS section,
  nt.id AS npc_type_id,
  nt.name AS npc_name,
  nt.level AS npc_level,
  nt.loottable_id,
  lte.lootdrop_id,
  lde.item_id,
  i.Name AS item_name,
  lde.chance,
  lde.disabled_chance,
  lde.minlevel,
  lde.maxlevel
FROM lootdrop_entries lde
JOIN items i ON i.id = lde.item_id
JOIN loottable_entries lte ON lte.lootdrop_id = lde.lootdrop_id
JOIN npc_types nt ON nt.loottable_id = lte.loottable_id
WHERE i.Name LIKE '%Defiant%'
ORDER BY nt.level, nt.id, lte.lootdrop_id, lde.item_id
LIMIT 500;

-- Defiant items sold by merchants.
SELECT
  'defiant_merchant_summary' AS section,
  COUNT(*) AS merchant_rows,
  COUNT(DISTINCT ml.merchantid) AS merchant_count,
  COUNT(DISTINCT ml.item) AS distinct_defiant_items
FROM merchantlist ml
JOIN items i ON i.id = ml.item
WHERE i.Name LIKE '%Defiant%';

SELECT
  'defiant_merchant_entries' AS section,
  ml.merchantid,
  ml.slot,
  ml.item,
  i.Name,
  ml.faction_required,
  ml.level_required,
  ml.min_expansion,
  ml.max_expansion,
  ml.classes_required,
  ml.probability
FROM merchantlist ml
JOIN items i ON i.id = ml.item
WHERE i.Name LIKE '%Defiant%'
ORDER BY ml.merchantid, ml.slot, ml.item
LIMIT 300;

-- Optional-table existence hints for later manual follow-up.
SELECT
  'optional_defiant_source_table_presence' AS section,
  t.TABLE_NAME,
  t.TABLE_ROWS,
  t.ENGINE
FROM information_schema.TABLES t
WHERE t.TABLE_SCHEMA = DATABASE()
  AND t.TABLE_NAME IN (
    'tradeskill_recipe_entries',
    'ground_spawns',
    'forage',
    'fishing',
    'starting_items',
    'object_contents',
    'npc_spells_entries'
  )
ORDER BY t.TABLE_NAME;

-- If the core source tables are already clean, this should report 0/0/0.
SELECT
  'defiant_spawn_source_recovery_preconditions' AS section,
  (SELECT COUNT(*)
   FROM lootdrop_entries lde
   JOIN items i ON i.id = lde.item_id
   WHERE i.Name LIKE '%Defiant%') AS lootdrop_rows_to_review,
  (SELECT COUNT(*)
   FROM merchantlist ml
   JOIN items i ON i.id = ml.item
   WHERE i.Name LIKE '%Defiant%') AS merchant_rows_to_review,
  (SELECT COUNT(*)
   FROM items i
   WHERE i.Name LIKE '%Defiant%') AS defiant_items_retained_for_reference;
